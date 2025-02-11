import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotify/controllers/home_controller.dart';
import 'package:spotify/utils/app_strings.dart';
import 'package:spotify/utils/search_type.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.search,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => controller.search(value),
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.search_sharp,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Obx(() => Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          controller.searchType.value = SearchType.album,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            controller.searchType.value == SearchType.album
                                ? Colors.green
                                : Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                            side: BorderSide(
                                color: controller.searchType.value !=
                                        SearchType.album
                                    ? Colors.white
                                    : Colors.transparent)),
                      ),
                      child: Text(AppStrings.albums,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          controller.searchType.value = SearchType.artist,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            controller.searchType.value == SearchType.artist
                                ? Colors.green
                                : Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                            side: BorderSide(
                                color: controller.searchType.value !=
                                        SearchType.artist
                                    ? Colors.white
                                    : Colors.transparent)),
                      ),
                      child: Text(AppStrings.artists,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                )),
          ),
          SizedBox(height: 8),
          Expanded(
            child: Stack(
              children: [
                Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                        child: CircularProgressIndicator(color: Colors.green));
                  }
                  if (controller.artistSearchResults.isEmpty &&
                      controller.searchType.value == SearchType.artist) {
                    return Center(
                        child: Text(AppStrings.noArtistsFound,
                            style: TextStyle(color: Colors.white54)));
                  }
                  if (controller.albumSearchResults.isEmpty &&
                      controller.searchType.value == SearchType.album) {
                    return Center(
                        child: Text(AppStrings.noAlbumsFound,
                            style: TextStyle(color: Colors.white54)));
                  }
                  return Container();
                }),
                Obx(() {
                  return IndexedStack(
                      index: controller.searchType.value == SearchType.album
                          ? 0
                          : 1,
                      children: [
                        GridView.builder(
                          controller: controller.albumScrollController,
                          padding: EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: controller.albumSearchResults.length,
                          itemBuilder: (context, index) {
                            var album = controller.albumSearchResults[index];
                            return Stack(children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: album.imageUrl.isNotEmpty
                                        ? Image.network(album.imageUrl,
                                            fit: BoxFit.cover)
                                        : Container(
                                            height: 150,
                                            color: Colors.grey[800]),
                                  ),
                                  SizedBox(height: 5),
                                  Text(album.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(album.artist,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white54)),
                                  Text(album.albumTypeText,
                                      style: TextStyle(color: Colors.white54)),
                                ],
                              ),
                              // Positioned.fill(
                              //     child: Material(
                              //         color: Colors.transparent,
                              //         child: InkWell(
                              //           splashColor: Colors.green.withAlpha(77),
                              //           onTap: () {},
                              //         )))
                            ]);
                          },
                        ),
                        ListView.builder(
                          controller: controller.artistScrollController,
                          padding: EdgeInsets.all(16),
                          itemCount: controller.artistSearchResults.length,
                          itemBuilder: (context, index) {
                            var artist = controller.artistSearchResults[index];
                            return ListTile(
                              leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors
                                      .white54, // Background color for the icon
                                  child: ClipOval(
                                    child: artist.imageUrl.isNotEmpty
                                        ? Image.network(artist.imageUrl,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover)
                                        : Icon(Icons.person,
                                            color: Colors.grey[300], size: 50),
                                  )),
                              title: Text(artist.name,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              // onTap: () {},
                            );
                          },
                        )
                      ]);
                })
              ],
            ),
          ),
        ],
      ),
    );
  }
}
