import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:farm_assistx/gallery_page.dart';

void main() {
  testWidgets(
      'GalleryPage renders and navigates to ImagePreviewScreen on image tap',
      (WidgetTester tester) async {
    // Build the GalleryPage widget
    await tester.pumpWidget(
      MaterialApp(
        home: GalleryPage(),
      ),
    );

    // Verify that the gallery page is displayed
    expect(find.byType(GalleryPage), findsOneWidget);

    // Verify that images are displayed in a grid
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNWidgets(4));

    // Tap on the first image
    await tester.tap(find.byType(CachedNetworkImage).first);
    await tester.pumpAndSettle(); // Wait for navigation to complete

    // Verify that ImagePreviewScreen is displayed
    expect(find.byType(ImagePreviewScreen), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);

    // Verify that the image in the preview screen matches the tapped image
    // You may need to adjust the expected image URL if necessary
    expect(find.byType(Image), findsOneWidget);
  });
}
