using System;
using System.Runtime.InteropServices;
using System.Text;
using System.Collections.Generic;
using System.Threading;

namespace Bind {

    public class Support {

/// Initialize

        private static readonly List<Delegate> bind_delegates_ = new List<Delegate>();

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        private delegate void RunAwaitingNativeActions_Delegate_();

        public static void Init() {
            // Should be called from C# main thread

            // Register methods
            var RunAwaitingNativeActions_delegate_ = new RunAwaitingNativeActions_Delegate_(RunAwaitingNativeActions);
            bind_delegates_.Add(RunAwaitingNativeActions_delegate_);
            IntPtr RunAwaitingNativeActions_ptr_ = Marshal.GetFunctionPointerForDelegate(RunAwaitingNativeActions_delegate_);

            CS_Bind_Support_nativeInit(RunAwaitingNativeActions_ptr_);

        }

        public static void Update() {
            // Should be called from C# main thread

            FlushMainThreadActions();
            ScheduleAutoReleaseUTF8CStrings();
        }

        private static void ScheduleAutoReleaseUTF8CStrings() {
            // Moving from main to native then from native to main thread
            // will ensure the allocated strings that need to be released
            // will have been copied as needed.
            if (_autoReleaseUTF8CStringPool.Count > 0) {
                List<IntPtr> toRelease = new List<IntPtr>();
                while (_autoReleaseUTF8CStringPool.TryDequeue(out IntPtr ptr))
                {
                    toRelease.Add(ptr);
                }
                RunInNativeThread(() => {
                    RunInMainThread(() => {
                        for (IntPtr ptr in toRelease) {
                            ReleaseUTF8CString(ptr);
                        }
                    });
                });
            }
        }

        private static void FlushMainThreadActions() {

            FlushMainThreadActions();

        }

        public static void NotifyReady() {

            CS_Bind_Support_notifyReady();

        }

/// Helpers for native

        public static void NotifyDispose(IntPtr address) {

            Support.RunInNativeThread(() => {
                CS_Bind_Support_releaseHObject(address);
            });

        }

/// Native calls

        /** Utility to let C# side notify native (haxe) side that it is ready and can call C# stuff. This is not always necessary and is just a convenience when the setup requires it. */
        [DllImport(Bind_DllName, CallingConvention = CallingConvention.Cdecl)]
        private static extern void CS_Bind_Support_notifyReady();

        [DllImport(Bind_DllName, CallingConvention = CallingConvention.Cdecl)]
        private static extern void CS_Bind_Support_nativeInit();

        [DllImport(Bind_DllName, CallingConvention = CallingConvention.Cdecl)]
        private static extern void CS_Bind_Support_releaseHObject(IntPtr address);

/// Converters

        public static string UTF8CStringToString(IntPtr ptr) {

            if (ptr == IntPtr.Zero)
                return null;

            // Find the length of the string (null-terminated)
            int length = 0;
            while (Marshal.ReadByte(ptr, length) != 0)
                length++;

            // Allocate a byte array and copy the bytes
            byte[] buffer = new byte[length];
            Marshal.Copy(ptr, buffer, 0, length);

            // Convert to string
            return System.Text.Encoding.UTF8.GetString(buffer);

        }

        private static readonly ConcurrentQueue<IntPtr> _autoReleaseUTF8CStringPool = new ConcurrentQueue<IntPtr>();

        public static IntPtr StringToUTF8CString(string str, bool autoRelease = true)
        {
            if (str == null)
                return IntPtr.Zero;

            // Convert string to UTF-8 byte array
            byte[] utf8Bytes = Encoding.UTF8.GetBytes(str);

            // Allocate unmanaged memory for the byte array with an extra byte for the null terminator
            IntPtr ptr = Marshal.AllocHGlobal(utf8Bytes.Length + 1);

            // Copy the byte array to unmanaged memory
            Marshal.Copy(utf8Bytes, 0, ptr, utf8Bytes.Length);

            // Add the null terminator
            Marshal.WriteByte(ptr, utf8Bytes.Length, 0);

            // Add to auto-release pool if enabled and requested
            if (autoRelease && Interlocked.CompareExchange(ref _isEnabled, 1, 1) == 1)
            {
                _autoReleaseUTF8CStringPool.Enqueue(ptr);
            }

            return ptr;
        }

        public static void ReleaseUTF8CString(IntPtr ptr)
        {
            if (ptr != IntPtr.Zero) {
                Marshal.FreeHGlobal(ptr);
            }
        }

/// Thread safety

        private static readonly Queue<Action> nativeThreadQueue = new Queue<Action>();

        private static readonly Queue<Action> mainThreadQueue = new Queue<Action>();

        private static bool useNativeThreadQueue = false;

        private static int nativeThreadId = 0;

        public static void SetUseNativeThreadQueue(bool value) {
            useNativeThreadQueue = value;
            nativeThreadId = 0;
        }

        public static bool IsUseNativeThreadQueue() {
            return useNativeThreadQueue;
        }

        static void PushNativeThreadAction(Action a) {

            lock (nativeThreadQueue) {
                nativeThreadQueue.Enqueue(a);
                CS_Bind_Support_nativeSetHasActions(1);
            }

        }

        static void PushMainThreadAction(Action a) {

            lock (mainThreadQueue) {
                mainThreadQueue.Enqueue(a);
            }

        }

        /** Called by native/C to run an Action from its thread */
        public static void RunAwaitingNativeActions() {

            List<Action> toRun = new List<Action>();
            lock (nativeThreadQueue) {
                if (nativeThreadId == 0) Thread.CurrentThread.ManagedThreadId;
                CS_Bind_Support_nativeSetHasActions(0);
                while (nativeThreadQueue.Count > 0)
                {
                    toRun.Add(nativeThreadQueue.Dequeue());
                }
            }
            foreach (Action a in toRun) {
                a();
            }

        }

        private class SyncResult
        {
            public volatile bool IsResolved;
            public readonly ManualResetEvent WaitHandle = new ManualResetEvent(false);
        }

        public static bool IsNativeThread() {

            if (useNativeThreadQueue) {
                if (nativeThreadId == 0) return !IsMainThread();
                return nativeThreadId ==
            }

        }

        // Your existing async method
        public static void RunInNativeThread(Action a)
        {
            if (UseNativeThreadActionStack)
            {
                PushNativeThreadAction(a);
            }
            else
            {
                RunInMainThread(a);
            }
        }

        // New synchronous version
        public static void RunInNativeThreadSync(Action a)
        {
            if (!IsNativeThread())
            {
                var result = new SyncResult();

                RunInNativeThread(() =>
                {
                    try
                    {
                        a();
                    }
                    finally
                    {
                        result.IsResolved = true;
                        result.WaitHandle.Set();
                    }
                });

                result.WaitHandle.WaitOne();
            }
            else
            {
                a();
            }
        }

        public static void RunInMainThread(Action a) {

            if (!IsMainThread()) {
                PushMainThreadAction(a);
            }
            else {
                a();
            }

        }

        public static void RunInMainThreadSync(Action a) {

            if (!IsNativeThread())
            {
                var result = new SyncResult();

                RunInNativeThread(() =>
                {
                    try
                    {
                        a();
                    }
                    finally
                    {
                        result.IsResolved = true;
                        result.WaitHandle.Set();
                    }
                });

                result.WaitHandle.WaitOne();
            }
            else
            {
                a();
            }

        }

        /** Inform native/C that some Action instances are waiting to be run from native thread. */
        [DllImport(Bind_DllName, CallingConvention = CallingConvention.Cdecl)]
        private static extern void CS_Bind_Support_nativeSetHasActions(int value);

/// JSON

        [Serializable]
        private class Bind_Json_Array
        {
            public string[] a;
        }

        [Serializable]
        private class Bind_Json_Dict
        {
            public string[][] o;
        }

        [Serializable]
        private class Bind_Json_Value
        {
            public string v;
            public string t;
        }

        [Serializable]
        private class Bind_Json_String
        {
            public string value;
        }

        private static object ParseWrappedJsonValue(string value, char type)
        {
            switch (type)
            {
                case 'n': return null;
                case 's': return value;
                case 'b': return value[0] != '0';
                case 'd': return double.Parse(value, System.Globalization.CultureInfo.InvariantCulture);
                case 'a': // array
                    var wrapper = JsonUtility.FromJson<Bind_Json_Array>("{\"a\":" + value + "}");
                    var array = new object[wrapper.a.Length / 2];
                    for (int i = 0; i < array.Length; i++)
                    {
                        array[i] = ParseWrappedJsonValue(wrapper.a[i * 2], wrapper.a[i * 2 + 1][0]);
                    }
                    return array;
                case 'o': // object/dictionary
                    return JSONStringToObject("{\"o\":" + value + "}");
                default:
                    return value;
            }
        }

        public static object JSONStringToObject(string json) {

            if (json.StartsWith("{\"a\":"))
            {
                var wrapper = JsonUtility.FromJson<Bind_Json_Array>(json);
                var array = new object[wrapper.a.Length / 2];
                for (int i = 0; i < array.Length; i++)
                {
                    array[i] = ParseWrappedJsonValue(wrapper.a[i * 2], wrapper.a[i * 2 + 1][0]);
                }
                return array;
            }
            else if (json.StartsWith("{\"o\":"))
            {
                var wrapper = JsonUtility.FromJson<Bind_Json_Dict>(json);
                var dict = new Dictionary<string, object>(wrapper.o.Length);
                foreach (var pair in wrapper.o)
                {
                    dict[pair[0]] = ParseWrappedJsonValue(pair[1], pair[2][0]);
                }
                return dict;
            }
            else // primitive value
            {
                var wrapper = JsonUtility.FromJson<Bind_Json_Value>(json);
                return ParseWrappedJsonValue(wrapper.v, wrapper.t[0]);
            }

        }

        public static ArrayList<object> JSONStringToArrayList(string json) {

            object[] array = (object[]) JSONStringToObject(json);
            if (array != null) {
                return new ArrayList<object>(array);
            }
            else {
                return null;
            }
        }

        public static string ObjectToJSONString(object value) {
        {
            if (value == null)
                return "null";

            // Handle primitive types
            if (value is string)
                return JsonUtility.ToJson(new Bind_Json_String { value = (string)value }).Substring(9).TrimEnd('}');
            if (value is bool)
                return ((bool)value).ToString().ToLower();
            if (value is int || value is float || value is double)
                return value.ToString();

            // Handle arrays and lists
            if (value is IList list)
            {
                List<string> items = new List<string>();
                foreach (object item in list)
                    items.Add(WriteJson(item));
                return "[" + string.Join(",", items) + "]";
            }

            // Handle dictionaries
            if (value is IDictionary dict)
            {
                List<string> items = new List<string>();
                foreach (DictionaryEntry entry in dict)
                {
                    if (entry.Key is string)
                        items.Add("\"" + (string)entry.Key + "\":" + WriteJson(entry.Value));
                }
                return "{" + string.Join(",", items) + "}";
            }

            throw new ArgumentException($"Unsupported type: {value.GetType()}");
        }

    }

    public class HObject : IDisposable
    {
        private IntPtr _address;
        private bool _disposed;

        public HObject(IntPtr address)
        {
            _address = address;
        }

        ~HObject()
        {
            Dispose(false);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!_disposed)
            {
                if (_address != IntPtr.Zero)
                {
                    Support.NotifyDispose(_address);
                    _address = IntPtr.Zero;
                }
                _disposed = true;
            }
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
    }

}