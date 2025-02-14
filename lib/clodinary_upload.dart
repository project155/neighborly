import 'package:cloudinary/cloudinary.dart';

Future<String?>  getClodinaryUrl(String image) async {

  final cloudinary = Cloudinary.signedConfig(
    cloudName: 'dkwnu8zei',
    apiKey: '298339343829723',
    apiSecret: 'T9q3BURXE2-Rj6Uv4Dk9bSzd7rY',
  );

   final response = await cloudinary.upload(
        file: image,
        resourceType: CloudinaryResourceType.image,
      );
  return response.secureUrl;
  
} 