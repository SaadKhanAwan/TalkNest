import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart' as player;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talknest/models/appuser.dart';
import 'package:talknest/viewmodel/services/firebaseservices/firebase_apis.dart';
import 'package:audio_waveforms/audio_waveforms.dart' as waveforms;
import 'package:uuid/uuid.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseApi _firebaseApi = FirebaseApi();
  final TextEditingController controller = TextEditingController();
  Stream<QuerySnapshot>? _messageStream;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final waveforms.RecorderController recorderController =
      waveforms.RecorderController();
  late player.AudioPlayer audioPlayer;
  final ImagePicker _picker = ImagePicker();
  String? selectedImageUrl;
  File? selectedImageFile;
  String? uploadedImageUrl;
  String mediaType = '';
  File? selectedMediaFile;
  String? uploadedMediaUrl;

  bool isRecording = false;
  String recordingDuration = "00:00";
  Timer? _timer;
  String? currentlyPlayingId;

  Stream<QuerySnapshot>? get messageStream => _messageStream;

  ChatProvider({required String userID}) {
    _init(userID: userID);
  }

  void _init({required String userID}) {
    initializeMessages(userID);
    getStatus(id: userID);
    _initializeRecorder();
    recorderController.record();
    audioPlayer = player.AudioPlayer();

    // Add a listener to handle when playback completes
    audioPlayer.onPlayerComplete.listen((event) {
      currentlyPlayingId = null;
      notifyListeners();
    });
  }

  Future<void> _initializeRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    await _recorder.openRecorder();
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));
  }

  void startRecording() async {
    recorderController.record();
    final directory = await getApplicationDocumentsDirectory();

    // Generate a unique filename using UUID
    final uniqueFileName = 'audio_message_${Uuid().v4()}.aac';
    final path = '${directory.path}/$uniqueFileName';

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.aacADTS,
      bitRate: 32000,
    );

    isRecording = true;
    recordingDuration = "00:00";
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final seconds = timer.tick % 60;
      final minutes = (timer.tick ~/ 60) % 60;
      recordingDuration =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      notifyListeners();
    });
  }

  Future<void> stopRecording(String targetUserId) async {
    String? path = await _recorder.stopRecorder();
    _timer?.cancel();

    isRecording = false;
    recordingDuration = "00:00";
    notifyListeners();

    if (path != null) {
      try {
        await sendAudioMessage(
          targetUserId: targetUserId,
          audioFilePath: path,
          duration: recordingDuration,
        );
      } catch (e) {
        log("Error sending audio message: $e");
      }
    }
  }

  Future<void> playAudio(String audioUrl, String messageId) async {
    // Stop the currently playing audio if it's different from the one being played
    if (currentlyPlayingId != null && currentlyPlayingId != messageId) {
      await audioPlayer.stop(); // Stop the currently playing audio
    }

    if (currentlyPlayingId == messageId) {
      // Pause if the same audio is already playing
      await audioPlayer.pause();
      currentlyPlayingId = null;
    } else {
      // Play the new audio
      await audioPlayer.setSource(player.UrlSource(audioUrl));
      await audioPlayer.resume();
      currentlyPlayingId = messageId;
    }

    notifyListeners();
  }

  void cancelRecording() {
    _recorder.stopRecorder();
    _timer?.cancel();
    currentlyPlayingId = null;
    isRecording = false;
    recordingDuration = "00:00";
    notifyListeners();
  }

  void initializeMessages(String targetUserId) {
    _messageStream = _firebaseApi.initializeMessages(targetUserId);
    notifyListeners();
  }

  Future<void> sendMessage(String targetUserId) async {
    if (controller.text.isNotEmpty ||
        uploadedMediaUrl != null ||
        uploadedImageUrl != null) {
      final messageText = controller.text;
      controller.clear();

      await _firebaseApi.sendMessage(
        targetUserId: targetUserId,
        messageText: messageText,
        imageUrl: mediaType == 'image' ? uploadedMediaUrl : null,
      );

      // Clear selected media after sending
      clearSelectedMedia();
    }
  }

  Stream<AppUser?> getUserData({userId}) {
    return _firebaseApi.getUserStatus(userId: userId);
  }

  void getStatus({id}) {
    _firebaseApi.markMessagesAsRead(id);
  }

  Future<void> sendAudioMessage(
      {required String targetUserId,
      required String audioFilePath,
      required String duration}) async {
    try {
      await _firebaseApi.sendAudioMessage(
        audioFilePath: audioFilePath,
        duration: duration,
        targetUserId: targetUserId,
      );
    } catch (e) {
      log("Error in sendAudioMessage: $e");
    }
  }

  void setSelectedImage(String imageUrl) {
    selectedImageUrl = imageUrl;
    notifyListeners();
  }

  Future<void> pickMedia() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedMediaFile = File(pickedFile.path);
      mediaType = 'image';

      // Show loading indicator while uploading
      notifyListeners();

      uploadedMediaUrl = await _firebaseApi.uploadImage(selectedMediaFile!);

      // Hide loading after upload completes
      notifyListeners();
    } else {
      log("No media selected.");
    }
  }

  void clearSelectedMedia() {
    selectedMediaFile = null;
    uploadedMediaUrl = null;
    mediaType = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    audioPlayer.release();
    audioPlayer = player.AudioPlayer();
    _timer?.cancel();
    super.dispose();
  }
}
