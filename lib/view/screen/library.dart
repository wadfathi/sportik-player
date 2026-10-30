import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sportik_player/controller/playercontroller.dart';
import 'package:sportik_player/view/screen/player.dart';

const _bg = Color(0xFF080D18);
const _panel = Color(0xFF121C2D);
const _accent = Color(0xFF20D6C7);

class VideoLibraryPage extends StatefulWidget {
  const VideoLibraryPage({super.key});

  @override
  State<VideoLibraryPage> createState() => _VideoLibraryPageState();
}

class _VideoLibraryPageState extends State<VideoLibraryPage> {
  List<AssetPathEntity> albums = [];
  List<AssetEntity> videos = [];

  AssetPathEntity? selectedAlbum;

  bool loading = true;
  String query = '';
  String error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({AssetPathEntity? album}) async {
    if (mounted) {
      setState(() {
        loading = true;
        error = '';
      });
    }

    try {
      final permission = await PhotoManager.requestPermissionExtend();

      if (!permission.isAuth && !permission.hasAccess) {
        if (!mounted) return;

        setState(() {
          error = 'نحتاج إذن الوصول إلى الفيديوهات لعرض مكتبتك.';
          loading = false;
        });
        return;
      }

      final paths = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        hasAll: true,
      );

      final all = paths.isNotEmpty ? paths.first : null;
      final target = album ?? selectedAlbum ?? all;

      final list = target == null
          ? <AssetEntity>[]
          : await target.getAssetListPaged(
              page: 0,
              size: 500,
            );

      if (!mounted) return;

      setState(() {
        albums = paths;
        selectedAlbum = target;
        videos = list;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'تعذر قراءة مكتبة الفيديوهات. حاول تحديث الصفحة.';
        loading = false;
      });
    }
  }

  Future<void> _play(AssetEntity asset) async {
    final file = await asset.file;

    if (file == null || !mounted) return;

    final args = <String, dynamic>{
      'localFilePath': file.path,
      'localTitle': asset.title ?? 'فيديو محلي',
    };

    Get.to(() {
      Get.put(Playercontroller(args));
      return const Player();
    });
  }

  String _duration(Duration d) {
    return '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
        '${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = videos.where((v) {
      return (v.title ?? '').toLowerCase().contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: _accent,
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(.13),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.play_circle_fill_rounded,
                          color: _accent,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SPORTIK',
                              style: TextStyle(
                                color: _accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 3,
                              ),
                            ),
                            Text(
                              'مكتبة الفيديو',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _load,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search field
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      onChanged: (v) {
                        setState(() => query = v);
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'ابحث عن فيديو...',
                        hintStyle: TextStyle(color: Colors.white38),
                        icon: Icon(Icons.search, color: _accent),
                      ),
                    ),
                  ),
                ),
              ),

              // Albums title
              SliverToBoxAdapter(
                child: _sectionTitle(
                  'المجلدات',
                  Icons.folder_rounded,
                ),
              ),

              // Albums list
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 104,
                  child: loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: _accent,
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                          ),
                          itemCount: albums.length,
                          itemBuilder: (context, index) {
                            final album = albums[index];
                            final active = selectedAlbum?.id == album.id;

                            return InkWell(
                              onTap: () => _load(album: album),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 118,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: active
                                      ? _accent.withOpacity(.16)
                                      : _panel,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: active ? _accent : Colors.white10,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.folder_rounded,
                                      color: active
                                          ? _accent
                                          : Colors.white70,
                                      size: 27,
                                    ),
                                    const Spacer(),
                                    Text(
                                      album.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                    FutureBuilder<int>(
                                      future: album.assetCountAsync,
                                      builder: (context, snapshot) {
                                        final count = snapshot.data ?? 0;

                                        return Text(
                                          '$count فيديو',
                                          style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 10,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(width: 10);
                          },
                        ),
                ),
              ),

              // Videos title
              SliverToBoxAdapter(
                child: _sectionTitle(
                  query.isEmpty ? 'الفيديوهات' : 'نتائج البحث',
                  Icons.video_library_rounded,
                ),
              ),

              // Loading
              if (loading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _accent,
                    ),
                  ),
                )

              // Error
              else if (error.isNotEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.video_library_outlined,
                            color: _accent,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            error,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _load,
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )

              // Empty library
              else if (filtered.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'لا توجد فيديوهات في هذا المجلد',
                      style: TextStyle(
                        color: Colors.white54,
                      ),
                    ),
                  ),
                )

              // Videos grid
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final video = filtered[index];

                        return _VideoCard(
                          asset: video,
                          duration: _duration(video.videoDuration),
                          onTap: () => _play(video),
                        );
                      },
                      childCount: filtered.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.08,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 13),
      child: Row(
        children: [
          Icon(
            icon,
            color: _accent,
            size: 19,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.asset,
    required this.duration,
    required this.onTap,
  });

  final AssetEntity asset;
  final String duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.white10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FutureBuilder<Uint8List?>(
                    future: asset.thumbnailDataWithSize(
                      const ThumbnailSize(420, 260),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return Container(
                          color: Colors.white10,
                          child: const Icon(
                            Icons.movie_rounded,
                            color: Colors.white24,
                            size: 38,
                          ),
                        );
                      }

                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 9,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white70,
                      size: 42,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Text(
                asset.title ?? 'فيديو بدون اسم',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
