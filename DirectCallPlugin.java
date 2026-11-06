package com.gomezardo.app;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.speech.RecognizerIntent;
import androidx.activity.result.ActivityResult;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.PermissionState;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.ActivityCallback;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;
import com.getcapacitor.annotation.PermissionCallback;
import java.util.ArrayList;

@CapacitorPlugin(
  name = "DirectCall",
  permissions = { @Permission(strings = { Manifest.permission.CALL_PHONE }, alias = "call") }
)
public class DirectCallPlugin extends Plugin {

  @PluginMethod
  public void dial(PluginCall call) {
    String number = call.getString("number");
    if (number == null || number.isEmpty()) {
      call.reject("Sem número");
      return;
    }
    if (getPermissionState("call") != PermissionState.GRANTED) {
      requestPermissionForAlias("call", call, "callPermsCallback");
      return;
    }
    doDial(call);
  }

  @PermissionCallback
  private void callPermsCallback(PluginCall call) {
    if (getPermissionState("call") == PermissionState.GRANTED) {
      doDial(call);
    } else {
      call.reject("Permissão de chamada negada");
    }
  }

  private void doDial(PluginCall call) {
    try {
      Intent i = new Intent(Intent.ACTION_CALL, Uri.parse("tel:" + Uri.encode(call.getString("number"))));
      i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      getActivity().startActivity(i);
      call.resolve();
    } catch (Exception e) {
      call.reject(e.getMessage());
    }
  }

  @PluginMethod
  public void listen(PluginCall call) {
    Intent i = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
    i.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
    i.putExtra(RecognizerIntent.EXTRA_LANGUAGE, "pt-PT");
    i.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5);
    i.putExtra(RecognizerIntent.EXTRA_PROMPT, "Fale agora");
    try {
      startActivityForResult(call, i, "listenResult");
    } catch (Exception e) {
      call.reject("Reconhecimento de voz indisponível");
    }
  }

  @ActivityCallback
  private void listenResult(PluginCall call, ActivityResult result) {
    if (call == null) return;
    if (result.getResultCode() == Activity.RESULT_OK && result.getData() != null) {
      ArrayList<String> r = result.getData().getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS);
      JSArray arr = new JSArray();
      if (r != null) {
        for (String s : r) arr.put(s);
      }
      JSObject o = new JSObject();
      o.put("results", arr);
      call.resolve(o);
    } else {
      call.reject("cancelado");
    }
  }
}
