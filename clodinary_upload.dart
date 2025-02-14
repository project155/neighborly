import 'package:cloudinary/cloudinary.dart';

Future<String?>  getClodinaryUrl(String image) async {

  final cloudinary = Cloudinary.signedConfig(
    cloudName: 'dob1wjjvc',
    apiKey: '615959474599611',
    apiSecret: 'jtw3DhqbBURDSKLERJ9tMMFAhr8',
  );

   final response = await cloudinary.upload(
        file: image,
        resourceType: CloudinaryResourceType.image,
      );
  return response.secureUrl;
  
} 