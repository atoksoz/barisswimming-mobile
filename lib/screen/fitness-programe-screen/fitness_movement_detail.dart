import 'dart:async';

import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../config/themes/bloc_theme.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';
import '../../data/model/movements_model.dart';

class FitnessMovementDetail extends StatefulWidget {
  const FitnessMovementDetail(
      {Key? key,
      required this.filteredMovements,
      required this.fitness_programe_id,
      required this.is_old_programe})
      : super(key: key);

  final List<MovementsModel> filteredMovements;
  final String fitness_programe_id;
  final bool is_old_programe;

  @override
  State<FitnessMovementDetail> createState() => _FitnessMovementDetailState();
}

class _FitnessMovementDetailState extends State<FitnessMovementDetail> {
  int currentIndex = 0;
  bool showVideo = false;
  late SharedPreferences prefs;
  VideoPlayerController? videoController;
  late YoutubePlayerController? youtubeController;
  Timer? _countdownTimer;
  int? _totalDurationSeconds;
  int _remainingDurationSeconds = 0;
  bool _isTimerRunning = false;

  MovementsModel get currentMovement => widget.filteredMovements[currentIndex];

  void initializeCurrentIndex() {
    final index = widget.filteredMovements.indexWhere(
      (movement) => movement.fitness_movement_id == widget.fitness_programe_id,
    );

      currentIndex = index != -1 ? index : 0;
  }

  @override
  void initState() {
    super.initState();
    initializeCurrentIndex();
    _initializeDurationTimer();
    initPrefs();
    initVideo();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      currentMovement.isDone =
          prefs.getBool(_movementKey(currentMovement)) ?? false;
    });
  }

  Future<void> initVideo() async {
    final videoUrl = currentMovement.default_video;

    showVideo = false;
    youtubeController = null;
    videoController?.dispose();
    videoController = null;

    if (videoUrl != null && videoUrl.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(videoUrl);
      if (videoId != null) {
        // YouTube videosu
        youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      } else if (videoUrl.endsWith(".mp4") ||
          Uri.tryParse(videoUrl)?.hasAbsolutePath == true) {
        // Normal video linki
        videoController != null && videoController!.value.isInitialized
            ? AspectRatio(
                aspectRatio: videoController!.value.aspectRatio,
                child: VideoPlayer(videoController!),
              )
            : const Text("Video yüklenemedi");
        //videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        //await videoController!.initialize();
      }
    }

    setState(() {});
  }

  String _movementKey(MovementsModel movement) =>
      "${widget.fitness_programe_id}_${movement.fitness_movement_id}";

  void goNext() {
    if (currentIndex < widget.filteredMovements.length - 1) {
      setState(() {
        currentIndex++;
        showVideo = false;
      });
      _initializeDurationTimer();
      initVideo();
      initPrefs();
    }
  }

  void goPrevious() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        showVideo = false;
      });
      _initializeDurationTimer();
      initVideo();
      initPrefs();
    }
  }

  void markAsDone() {
    final key = _movementKey(currentMovement);
    prefs.setBool(key, true);
    setState(() {
      currentMovement.isDone = true;
    });
  }

  @override
  void dispose() {
    youtubeController?.dispose();
    videoController?.dispose();
    _countdownTimer?.cancel();

    super.dispose();
  }

  void _initializeDurationTimer() {
    _countdownTimer?.cancel();
    final duration = currentMovement.duration;
    setState(() {
      if (duration != null && duration > 0) {
        _totalDurationSeconds = duration;
        _remainingDurationSeconds = duration;
      } else {
        _totalDurationSeconds = null;
        _remainingDurationSeconds = 0;
      }
      _isTimerRunning = false;
    });
  }

  bool get _hasDuration => _totalDurationSeconds != null && _totalDurationSeconds! > 0;
  bool get _hasTimerStarted => _isTimerRunning || (_hasDuration && _remainingDurationSeconds != (_totalDurationSeconds ?? 0));

  void _startTimer() {
    if (!_hasDuration) return;
    if (_remainingDurationSeconds <= 0) {
      _remainingDurationSeconds = _totalDurationSeconds ?? 0;
    }
    if (_remainingDurationSeconds <= 0) return;

    _countdownTimer?.cancel();
    setState(() {
      _isTimerRunning = true;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingDurationSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingDurationSeconds = 0;
          _isTimerRunning = false;
        });
      } else {
        setState(() {
          _remainingDurationSeconds--;
        });
      }
    });
  }

  void _pauseTimer() {
    if (!_isTimerRunning) return;
    _countdownTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _restartTimer() {
    if (!_hasDuration) return;
    _countdownTimer?.cancel();
    setState(() {
      _remainingDurationSeconds = _totalDurationSeconds ?? 0;
      _isTimerRunning = false;
    });
    _startTimer();
  }

  void _toggleTimer() {
    if (!_hasDuration) return;
    if (_isTimerRunning) {
      _pauseTimer();
    } else {
      if (_remainingDurationSeconds <= 0) {
        _remainingDurationSeconds = _totalDurationSeconds ?? 0;
      }
      _startTimer();
    }
  }

  String _formatDuration(int seconds) {
    if (seconds >= 60) {
      final minutes = seconds ~/ 60;
      final remaining = seconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
    }
    return '${seconds.toString()} sn';
  }

  String? _sanitizeText(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') {
      return null;
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final movement = currentMovement;
    final hasVideo =
        movement.default_video != null && movement.default_video!.isNotEmpty;
    final sanitizedSet = _sanitizeText(movement.set);
    final sanitizedRepeat = _sanitizeText(movement.repeat);

    return Scaffold(
      appBar: TopAppBarWidget(title: "Egzersizin Yapılışı"),
      body: widget.filteredMovements.isEmpty
          ? const Center(child: NoDataTextWidget())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${currentIndex + 1}/${widget.filteredMovements.length}",
                      style: TextStyle(
                          fontSize: 16, color: BlocTheme.theme.default900Color),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movement.fitness_movement_name ?? "Hareket Adı",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: showVideo
                              ? youtubeController != null
                                  ? YoutubePlayer(
                                      controller: youtubeController!)
                                  : videoController != null &&
                                          videoController!.value.isInitialized
                                      ? AspectRatio(
                                          aspectRatio: videoController!
                                              .value.aspectRatio,
                                          child: VideoPlayer(videoController!),
                                        )
                                      : const Text("Video yüklenemedi")
                              : currentMovement.default_image_url != null &&
                                      currentMovement
                                          .default_image_url!.isNotEmpty
                                  ? Image.network(
                                      currentMovement.default_image_url!,
                                      width: 300,
                                      height: 300,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          const Icon(Icons.image_not_supported,
                                              size: 64),
                                    )
                                  : const Icon(Icons.image_not_supported,
                                      size: 64),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (hasVideo) ...[
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25),
                              onTap: () {
                                setState(() {
                                  showVideo = !showVideo;
                                  if (showVideo) {
                                    if (videoController != null &&
                                        videoController!.value.isInitialized) {
                                      videoController!.play();
                                    }
                                  } else {
                                    videoController?.pause();
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      spreadRadius: 1,
                                      color: const Color.fromARGB(
                                          1, 249, 250, 251),
                                    )
                                  ],
                                  color: BlocTheme.theme
                                      .defaultWhiteColor, // Arka plan beyaz
                                  border: Border.all(
                                    color: BlocTheme
                                        .theme.default800Color, // Kenar rengi
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(25)),
                                ),
                                margin: const EdgeInsetsDirectional.fromSTEB(
                                    20, 12, 20, 0),
                                height: 50,
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        showVideo
                                            ? Icons.image
                                            : Icons.video_collection,
                                        size: 32,
                                        color: BlocTheme.theme
                                            .default800Color, // İkon rengi
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        showVideo
                                            ? "Görseli Göster"
                                            : "Videoyu Görüntüle",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: BlocTheme.theme
                                              .default800Color, // Yazı rengi
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (sanitizedSet != null)
                      Text("Set: $sanitizedSet",
                        style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            color: BlocTheme.theme.default900Color)),
                    if (sanitizedRepeat != null)
                      Text("Tekrar: $sanitizedRepeat",
                        style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            color: BlocTheme.theme.default900Color)),
                    if (_hasDuration && !movement.isDone) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _formatDuration(_remainingDurationSeconds),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: BlocTheme.theme.defaultBlackColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: _hasDuration
                                    ? () {
                                        if (_hasTimerStarted) {
                                          _restartTimer();
                                        } else {
                                          _startTimer();
                                        }
                                      }
                                    : null,
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        spreadRadius: 1,
                                        color: const Color.fromARGB(
                                            1, 249, 250, 251),
                                      )
                                    ],
                                    color: BlocTheme.theme.defaultWhiteColor,
                                    border: Border.all(
                                      color: BlocTheme.theme.default800Color,
                                    ),
                                    borderRadius:
                                        const BorderRadius.all(Radius.circular(25)),
                                  ),
                                  margin: const EdgeInsetsDirectional.fromSTEB(
                                      20, 12, 20, 0),
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      _hasTimerStarted ? 'Baştan Başla' : 'Başla',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            BlocTheme.theme.default800Color,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_hasTimerStarted) ...[
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: _hasDuration ? _toggleTimer : null,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          spreadRadius: 1,
                                          color: const Color.fromARGB(
                                              1, 249, 250, 251),
                                        )
                                      ],
                                      color: BlocTheme.theme.default500Color,
                                      border: Border.all(
                                        color: BlocTheme.theme.default800Color,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(25)),
                                    ),
                                    margin: const EdgeInsetsDirectional.fromSTEB(
                                        0, 12, 20, 0),
                                    height: 50,
                                    child: Center(
                                      child: Text(
                                        _isTimerRunning ? 'Durdur' : 'Devam Et',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: BlocTheme.theme.default900Color,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    if (movement.explanation != null &&
                        movement.explanation!.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      const Text(
                        "Açıklama",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Html(
                        data: movement.explanation ?? '',
                      ),
                      const SizedBox(height: 5),
                    ],
                    if (movement.detail != null &&
                        movement.detail!.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      const Text(
                        "Detay",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Html(
                        data: movement.detail ?? '',
                      ),
                    ],
                    if (movement.isDone == true) ...[
                      const SizedBox(height: 5),
                      Text("Yapıldı mı? ${movement.isDone ? "Evet" : "Hayır"}",
                          style: TextStyle(
                            fontSize: 14,
                            color: BlocTheme.theme.default900Color,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                    SizedBox(
                      height: 5,
                    ),
                    if (!movement.isDone && widget.is_old_programe == false)
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25),
                              onTap: () {
                                markAsDone();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      spreadRadius: 1,
                                      color: const Color.fromARGB(
                                          1, 249, 250, 251),
                                    )
                                  ],
                                  color: BlocTheme.theme
                                      .defaultWhiteColor, // Arka plan beyaz
                                  border: Border.all(
                                    color: BlocTheme
                                        .theme.default800Color, // Kenar rengi
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(25)),
                                ),
                                margin: const EdgeInsetsDirectional.fromSTEB(
                                    20, 12, 20, 0),
                                height: 50,
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check,
                                        size: 32,
                                        color: BlocTheme.theme
                                            .default800Color, // İkon rengi
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "Hareketi Yaptım",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: BlocTheme.theme
                                              .default800Color, // Yazı rengi
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: goPrevious,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BlocTheme.theme.default500Color,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              "Önceki",
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: BlocTheme.theme.defaultBlackColor,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: goNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BlocTheme.theme.default500Color,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              "Sonraki",
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: BlocTheme.theme.defaultBlackColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
    );
  }
}
