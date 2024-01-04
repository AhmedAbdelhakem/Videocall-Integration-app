import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:videocallapp/app_brain.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

class AudioCallScreen extends StatefulWidget {
  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  late int _remoteUid = 0;
  late RtcEngine _engine;

  @override
  void initState() {
    initAgora();
    super.initState();
  }
  @override
  void dispose() {
    _engine.leaveChannel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black87,
            child: Center(
              child: _remoteUid == 0
                  ? Text(
                'Calling...',
                style: TextStyle(color: Colors.white),
              ) : Text(
                'Calling With $_remoteUid',
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 25.0, right: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    icon: Icon(
                      Icons.call_end,
                      size: 44,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

//  Functions

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();
    _engine = await RtcEngine.create(AgoraManager.appId);
    _engine.enableVideo();
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print('local user $uid joined Successfully');
        },
        userJoined: (int uid, int elapsed) {
          print('remote user $uid joined Successfully');
          setState(() => _remoteUid = uid);
        },
        userOffline: (int uid, UserOfflineReason reason) {
          print('remote user $uid left call');
          setState(() => _remoteUid = 0);
          Navigator.of(context).pop(true);
        },
      ),
    );
    await _engine.joinChannel(
      AgoraManager.token,
      AgoraManager.channelName,
      null,
      0,
    );
  }
  Widget _renderRemoteAudio(){
    if(_remoteUid !=0) {
      return Text(
        'Calling with $_remoteUid',
        style: TextStyle(color: Colors.white),
      );
    } else{
      return Text(
        'Calling...',
        style: TextStyle(color: Colors.white),
      );
    }
  }
}
