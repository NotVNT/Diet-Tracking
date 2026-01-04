import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../../../../common/custom_app_bar.dart';
import '../../../../common/snackbar_helper.dart';
import '../../../../features/home_page/presentation/widgets/navigation/bottom_navigation_bar.dart';
import '../../../../features/home_page/presentation/widgets/navigation/floating_action_button.dart';
import '../../../../features/home_page/presentation/widgets/navigation/home_navigation_handlers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../services/permission_service.dart';
import '../../services/video_analysis_service.dart';
import '../cubit/video_analysis_cubit.dart';
import '../cubit/video_analysis_state.dart';
import '../widgets/video_preview_widget.dart';
import '../widgets/video_recording.dart';

class VideoProcessingPage extends StatelessWidget {
  final VideoAnalysisService? service;
  const VideoProcessingPage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoAnalysisCubit(service: service),
      child: const VideoProcessingView(),
    );
  }
}

class VideoProcessingView extends StatefulWidget {
  const VideoProcessingView({super.key});

  @override
  State<VideoProcessingView> createState() => _VideoProcessingViewState();
}

class _VideoProcessingViewState extends State<VideoProcessingView> {
  Future<void> _pickVideo(BuildContext context) async {
    final permissionService = PermissionService();
    final cameraStatus = await permissionService
        .requestCameraPermissionStatus();
    final microphoneStatus = await permissionService
        .requestMicrophonePermissionStatus();

    if (cameraStatus.isDenied || microphoneStatus.isDenied) {
      if (context.mounted) {
        SnackBarHelper.showWarning(
          context,
          AppLocalizations.of(context)!.videoPermissionWarning,
        );
      }
      return;
    }

    if (cameraStatus == ph.PermissionStatus.permanentlyDenied ||
        microphoneStatus == ph.PermissionStatus.permanentlyDenied) {
      await permissionService.openAppSettings();
      return;
    }

    if (!context.mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<VideoAnalysisCubit>();

    try {
      final XFile? video = await navigator.push<XFile?>(
        MaterialPageRoute(builder: (_) => const VideoRecording()),
      );

      if (video != null) {
        // Goal/allergy will be fetched from user profile inside the cubit
        cubit.analyzeVideo(video);
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _onBottomNavTap(int index) {
    // This page is pushed on top of HomePage. When user taps a tab,
    // update HomeProvider and pop back to the main shell.
    HomeNavigationHandlers.onBottomNavTap(
      context,
      index,
      popCurrentRoute: true,
    );
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
          // Video Upload Section
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: BlocBuilder<VideoAnalysisCubit, VideoAnalysisState>(
                builder: (context, state) {
                  if (state is VideoAnalysisInitial) {
                    return Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickVideo(context),
                        label: Text(
                          AppLocalizations.of(context)!.videoUploadButton,
                        ),
                      ),
                    );
                  } else if (state is VideoAnalysisAnalyzing) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPreviewWidget(
                          videoFile: state.video,
                          onClear: () =>
                              context.read<VideoAnalysisCubit>().reset(),
                        ),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    );
                  } else if (state is VideoAnalysisSuccess) {
                    return VideoPreviewWidget(
                      videoFile: state.video,
                      onClear: () => context.read<VideoAnalysisCubit>().reset(),
                    );
                  } else if (state is VideoAnalysisFailure) {
                    if (state.video != null) {
                      return VideoPreviewWidget(
                        videoFile: state.video!,
                        onClear: () =>
                            context.read<VideoAnalysisCubit>().reset(),
                      );
                    }
                    return Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickVideo(context),
                        label: Text(
                          AppLocalizations.of(context)!.videoUploadButton,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          const Divider(height: 3, thickness: 5),
          // Instructions Section
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: BlocBuilder<VideoAnalysisCubit, VideoAnalysisState>(
                      builder: (context, state) {
                        if (state is VideoAnalysisAnalyzing) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is VideoAnalysisSuccess) {
                          return SingleChildScrollView(
                            child: Text(
                              state.recipe,
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        } else if (state is VideoAnalysisFailure) {
                          return Text(
                            state.message,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                        return Text(AppLocalizations.of(context)!.videoNoData);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        onRecordSelected: () => HomeNavigationHandlers.navigateToRecord(
          context,
          popCurrentRoute: true,
        ),
        onChatBotSelected: () => HomeNavigationHandlers.navigateToChatBot(
          context,
          popCurrentRoute: true,
        ),
        onScanFoodSelected: () => HomeNavigationHandlers.navigateToScanFood(
          context,
          replaceCurrentRoute: true,
        ),
        onReportSelected: () =>
            HomeNavigationHandlers.navigateToReport(context),
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
