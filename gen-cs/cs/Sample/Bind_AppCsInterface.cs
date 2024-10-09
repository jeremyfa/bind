// This file was generated with bind library

using Bind.Support;
using System;
using System.Runtime.InteropServices;
using UnityEngine;

namespace Sample {

    class Bind_AppCsInterface {

        /** Load audio */
        public static void Load(int audioId, IntPtr url, int autoplay, IntPtr onProgress, IntPtr onWarning, IntPtr onError) {
            if (!Bind.Support.isCSMainThread()) {
                Bind.Support.RunInCSMainThreadAsync(() => {
                    Bind_AppCsInterface.Load(audioId, url, autoplay, onProgress, onWarning, onError);
                });
            } else {
                int audioId_cs_ = audioId;
                string url_cs_ = Bind.Support.UTF8CStringToString(url);
                bool autoplay_cs_ = autoplay != 0 ? true : false;
                HObject onProgress_cs_hobj_ = onProgress == null ? null : new HObject(onProgress);
                Action<bool,bool,double,double> onProgress_cs_ = onProgress == null ? null : (bool playing, bool complete, double position) => {
                    int playing_csc_ = playing ? 1 : 0;
                    int complete_csc_ = complete ? 1 : 0;
                    double position_csc_ = position;
                    Bind.Support.RunInNativeThreadAsync(() => {
                        Bind_AppCsInterface.CS_Sample_AppCsInterface_CallN_BoolBoolDoubleVoid(onProgress_cs_hobj_.address, playing_csc_, complete_csc_, position_csc_);
                    });
                };
                HObject onWarning_cs_hobj_ = onWarning == null ? null : new HObject(onWarning);
                Action<string> onWarning_cs_ = onWarning == null ? null : () => {
                    Bind.Support.RunInNativeThreadAsync(() => {
                        Bind_AppCsInterface.CS_Sample_AppCsInterface_CallN_Void(onWarning_cs_hobj_.address);
                    });
                };
                HObject onError_cs_hobj_ = onError == null ? null : new HObject(onError);
                Action<string,int> onError_cs_ = onError == null ? null : (string error) => {
                    IntPtr error_csc_ = Bind.Support.StringToCSCString(error);
                    Bind.Support.RunInNativeThreadAsync(() => {
                        Bind_AppCsInterface.CS_Sample_AppCsInterface_CallN_StringVoid(onError_cs_hobj_.address, error_csc_);
                        Bind.Support.ReleaseCSCString(error_csc_);
                    });
                };
                AppCsInterface.Load(audioId_cs_, url_cs_, autoplay_cs_, onProgress_cs_, onWarning_cs_, onError_cs_);
            }
        }

        public static void Bind_RegisterMethods() {
        }
        [DllImport(Bind_DllName, CallingConvention = CallingConvention.Cdecl)]
        private static extern void CS_Sample_AppCsInterface_CallN_BoolBoolDoubleVoid(IntPtr address, int arg1, int arg2, double arg3);

        [DllImport(Bind_DllName, CallingConvention = CallingConvention.Cdecl)]
        private static extern void CS_Sample_AppCsInterface_CallN_StringVoid(IntPtr address, IntPtr arg1);

        [DllImport(Bind_DllName, CallingConvention = CallingConvention.Cdecl)]
        private static extern void CS_Sample_AppCsInterface_CallN_Void(IntPtr address);

    }

}

