class ImageProfile {
  const ImageProfile({
    required this.name,
    required this.maxWidth,
    required this.maxHeight,
    required this.quality,
  });

  final String name;
  final int maxWidth;
  final int maxHeight;
  final int quality;

  static const ImageProfile thumbnail = ImageProfile(
    name: 'thumbnail',
    maxWidth: 300,
    maxHeight: 300,
    quality: 82,
  );

  static const ImageProfile card = ImageProfile(
    name: 'card',
    maxWidth: 800,
    maxHeight: 800,
    quality: 85,
  );

  static const ImageProfile standard = ImageProfile(
    name: 'standard',
    maxWidth: 1200,
    maxHeight: 1200,
    quality: 86,
  );

  static const ImageProfile large = ImageProfile(
    name: 'large',
    maxWidth: 1920,
    maxHeight: 1920,
    quality: 88,
  );

  factory ImageProfile.custom({
    required String name,
    required int maxWidth,
    required int maxHeight,
    int quality = 85,
  }) {
    return ImageProfile(
      name: name,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      quality: quality.clamp(1, 100),
    );
  }
}
