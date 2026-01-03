import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/custom_app_bar.dart';
import '../../../../common/snackbar_helper.dart';
import '../../../../config/home_page_config.dart';
import '../../../../features/food_scanner/presentation/pages/food_scanner_page.dart';
import '../../../../features/home_page/presentation/pages/nutrition_summary_page.dart';
import '../../../../features/home_page/presentation/providers/home_provider.dart';
import '../../../../features/home_page/presentation/widgets/navigation/bottom_navigation_bar.dart';
import '../../../../features/home_page/presentation/widgets/navigation/floating_action_button.dart';
import '../../../../features/record_view_home/domain/entities/food_record_entity.dart';
import '../../../../features/record_view_home/presentation/cubit/record_cubit.dart';
import '../../../../features/record_view_home/presentation/cubit/record_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../services/video_analysis_service.dart';
import '../widgets/video_recording.dart';

class VideoProcessingPage extends StatefulWidget {
  final VideoAnalysisService? service;

  const VideoProcessingPage({super.key, this.service});

  @override
  State<VideoProcessingPage> createState() => _VideoProcessingPageState();
}

class _VideoProcessingPageState extends State<VideoProcessingPage> {
  late final VideoAnalysisService _service;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? VideoAnalysisService();
  }

  
  XFile? _videoFile;
  VideoPlayerController? _videoController;
  String? _recipeInstructions;
  bool _isAnalyzing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    // Request permissions
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    if (cameraStatus.isDenied || microphoneStatus.isDenied) {
      if (mounted) {
        SnackBarHelper.showWarning(context, AppLocalizations.of(context)!.videoPermissionWarning);
      }
      return;
    }

    if (cameraStatus.isPermanentlyDenied || microphoneStatus.isPermanentlyDenied) {
      if (mounted) {
        openAppSettings();
      }
      return;
    }

    if (!mounted) return;

    try {
      final XFile? video = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VideoRecording()),
      );
      
      if (video != null) {
        await _initializeVideo(video);
        _analyzeVideo(video);
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.videoPickError(e.toString());
      });
    }
  }

  Future<void> _initializeVideo(XFile video) async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.file(File(video.path));
    await _videoController!.initialize();
    setState(() {
      _videoFile = video;
      _errorMessage = null;
      _recipeInstructions = null;
    });
    _videoController!.play();
  }

  Future<void> _analyzeVideo(XFile video) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await _service.analyzeVideo(video.path);
      setState(() {
        _recipeInstructions = result.recipe;
      });
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.videoAnalysisError(e.toString());
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _navigateToRecord() {
    context.read<HomeProvider>().setCurrentIndex(HomePageConfig.recordIndex);
    Navigator.of(context).pop();
  }

  void _navigateToChatBot() {
    context.read<HomeProvider>().setCurrentIndex(HomePageConfig.chatBotIndex);
    Navigator.of(context).pop();
  }

  void _navigateToScanFood() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const FoodScannerPage()),
    );
  }

  void _navigateToReport() {
    final state = context.read<RecordCubit>().state;
    List<FoodRecordEntity> allRecords = [];
    if (state is RecordListLoaded) {
      allRecords = state.records;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NutritionSummaryPage(
          selectedDate: context.read<HomeProvider>().selectedDate,
          allRecords: allRecords,
        ),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    final provider = context.read<HomeProvider>();
    if (index == 0) {
      provider.setCurrentIndex(HomePageConfig.homeIndex);
      Navigator.of(context).pop();
    } else if (index == 3) {
      provider.setCurrentIndex(HomePageConfig.profileIndex);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.videoProcessingTitle,
        showBackButton: false,
      ),
      body: Column(
        children: [
          // Phần gửi video (Video Upload Section)
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: _videoFile == null
                  ? Center(
                      child: ElevatedButton.icon(
                        onPressed: _pickVideo,
                        label: Text(AppLocalizations.of(context)!.videoUploadButton),
                      ),
                    )
                  : _videoController != null && _videoController!.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : const Center(child: CircularProgressIndicator()),
            ),
          ),
          const Divider(height: 3, thickness: 5),
          // Hiện ra các bước hướng dẫn từ con thị giác (Instructions Section)
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.videoAnalysisTitle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (_isAnalyzing)
                    const Center(child: CircularProgressIndicator())
                  else if (_errorMessage != null)
                    Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error))
                  else if (_recipeInstructions != null)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _recipeInstructions!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  else
                    Text(AppLocalizations.of(context)!.videoNoData),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        onRecordSelected: _navigateToRecord,
        onChatBotSelected: _navigateToChatBot,
        onScanFoodSelected: _navigateToScanFood,
        onReportSelected: _navigateToReport,
        onUploadVideoSelected: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
