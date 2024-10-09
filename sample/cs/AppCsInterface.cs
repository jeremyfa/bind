using System;
using System.Runtime.InteropServices;
using UnityEngine;

namespace Sample {

    public class AppCsInterface {

        /** Load audio */
        protected static void Load(
            int audioId, string url, bool autoplay,
            Action<bool/*playing*/,bool/*complete*/,double/*position*/,double/*duration*/> onProgress,
            Action<string/*warning*/> onWarning,
            Action<string/*error*/,int/*kind*/> onError) {

            Debug.Log("AUDIO CREATE audioId="+audioId+" url="+url);
        }

    }

}
