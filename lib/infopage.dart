import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:neighborly/feedback.dart';
// import 'package:neighborly/feedback.dart'; // Uncomment if needed

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // Define your brand colors.
  final Color primaryColor = const Color.fromARGB(255, 9, 60, 83);
  final Color secondaryColor = const Color.fromARGB(255, 0, 115, 168);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      theme: ThemeData(
        primaryColor: primaryColor,
        fontFamily: 'Proxima', // Ensure Proxima is declared in pubspec.yaml
        appBarTheme: AppBarTheme(
          // The following properties will be overridden by our custom AppBar.
          color: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontFamily: 'Proxima',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      home: InfoPage(),
    );
  }
}

// Modified function now requires a BuildContext to create the back button.
PreferredSizeWidget buildGradientAppBar(BuildContext context, String title,
    {bool automaticallyImplyLeading = true}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(65),
    child: ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: AppBar(
        centerTitle: true,
        // Disable default leading; provide our custom back button.
        automaticallyImplyLeading: false,
        leading: automaticallyImplyLeading
            ? IconButton(
                icon: const Icon(CupertinoIcons.back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 9, 60, 83),
                Color.fromARGB(255, 0, 115, 168),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Proxima',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Added back button on Information page by setting automaticallyImplyLeading: true.
      appBar: buildGradientAppBar(context, 'Information', automaticallyImplyLeading: true),
      body: ListView(
        children: [
          _buildListTile(context, Icons.info, 'About Us', AboutUsPage()),
          _buildListTile(context, Icons.privacy_tip, 'Privacy Policy', PrivacyPolicyPage()),
          _buildListTile(context, Icons.help, 'Help & Support', HelpSupportPage()),
          _buildListTile(context, Icons.feedback, 'Feedback', FeedbackPage()),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 9, 60, 83)),
      title: Text(title, style: const TextStyle(fontFamily: 'Proxima')),
      trailing: const Icon(Icons.arrow_forward_ios, color: Color.fromARGB(255, 9, 60, 83)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}

class AboutUsPage extends StatelessWidget {
  // Markdown content for About Us
  final String markdownContent = """
Welcome to **Reportify**, your trusted platform for reporting incidents, emergencies, and local issues with ease. Our mission is to empower communities by providing a seamless and effective way to report, track, and resolve public concerns in real time.

### Our Vision
We envision a safer and more responsive society where individuals can actively contribute to community well-being by reporting issues that matter. By bridging the gap between citizens and authorities, Reportify strives to enhance public safety, accountability, and awareness.

### What We Do
**Reportify** is designed to streamline the reporting process for various incidents, including:
- **Disasters and Emergencies**: Report natural calamities like floods and landslides, ensuring authorities and citizens receive timely alerts.
- **Public Safety Issues**: Notify authorities about theft, bribery, rash driving, public boozing, illegal activities, and more.
- **Accidents and Road Problems**: Share real-time traffic incidents, roadblocks, and pothole reports to improve commuting.
- **Community Support & Engagement**: Offer aid through food donations, medicine support, and crowdfunding for emergency relief.
- **Lost and Found**: Help reunite lost items and people with their rightful owners during disasters or daily life.
- **Local Awareness & Events**: Discover nearby events, offers, and important community updates.
- **Essential Services**: Access contact details for auto drivers, electricians, plumbers, and other essential service providers.

### Why Choose Reportify?
- **Instant Reporting**: A user-friendly platform to report and notify relevant authorities quickly.
- **Real-Time Alerts**: Receive updates on reported incidents and safety warnings in your area.
- **Comprehensive Mapping**: GPS-integrated reports to provide precise locations for better response.
- **Community-Centric**: Encouraging citizen participation to foster a connected and responsible society.

At **Reportify**, we believe in creating a more informed and engaged community where every report makes a difference. Join us in making your city a safer and better place!

For any inquiries or support, contact us at:  
Email: [Your Contact Email]  
Address: [Your Address]
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildGradientAppBar(context, 'About Us'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Markdown(
          data: markdownContent,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: const TextStyle(fontSize: 16, fontFamily: 'Proxima'),
            h1: const TextStyle(fontFamily: 'Proxima', fontSize: 24, fontWeight: FontWeight.bold),
            h2: const TextStyle(fontFamily: 'Proxima', fontSize: 22, fontWeight: FontWeight.bold),
            h3: const TextStyle(fontFamily: 'Proxima', fontSize: 20, fontWeight: FontWeight.bold),
            listBullet: const TextStyle(fontFamily: 'Proxima', fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  // Markdown content for Privacy Policy
  final String markdownContent = """
**Privacy Policy**  
Effective Date: [Insert Date]  

**1. Introduction**  
Welcome to **Reportify**! Your privacy is important to us. This Privacy Policy explains how we collect, use, disclose, and protect your personal information when you use our app.

**2. Information We Collect**  
We collect the following types of information:

- **Personal Information**: When you register, submit reports, or interact with the app, we may collect details such as your name, email, phone number, and location.
- **Report Data**: Information you provide in your reports, including text, photos, videos, and location details.
- **Device and Usage Data**: Information about your device, IP address, app usage, and interactions to improve app functionality.
- **Location Data**: With your consent, we collect real-time location data to provide location-based services such as reporting incidents and navigation.

**3. How We Use Your Information**  
We use the collected data for:

- Processing and forwarding reports to relevant authorities.
- Enhancing user experience and improving app functionality.
- Sending important notifications and alerts.
- Ensuring security and preventing fraudulent activities.
- Conducting analytics and research to improve services.

**4. Information Sharing and Disclosure**  
We do not sell or share your personal information with third parties except in the following cases:

- **Authorities and Emergency Services**: Your reports and relevant details may be shared with law enforcement, government agencies, or emergency responders.
- **Service Providers**: We may share data with trusted third-party service providers to assist in app functionality and maintenance.
- **Legal Compliance**: If required by law, we may disclose information to comply with legal obligations or protect our rights.

**5. Data Security**  
We take appropriate security measures to protect your data against unauthorized access, alteration, or disclosure. However, no method of transmission over the internet is 100% secure.

**6. Your Rights and Choices**  
You have the following rights:

- **Access and Update**: You can review and update your personal information in the app settings.
- **Location Permissions**: You can enable or disable location services through your device settings.
- **Opt-Out**: You may opt out of receiving non-essential communications.

**7. Retention of Data**  
We retain your data as long as necessary to provide our services. You may request data deletion by contacting us.

**8. Third-Party Links and Services**  
Reportify may contain links to third-party websites or services. We are not responsible for their privacy practices, and we encourage you to review their privacy policies.

**9. Children's Privacy**  
Reportify is not intended for children under 13. We do not knowingly collect data from children. If we discover such data, we will delete it promptly.

**10. Changes to this Privacy Policy**  
We may update this Privacy Policy from time to time. Any changes will be posted within the app with the updated effective date.

**11. Contact Us**  
If you have any questions about this Privacy Policy, please contact us at:  
Email: [Your Contact Email]  
Address: [Your Address]

By using Reportify, you agree to the terms of this Privacy Policy.
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildGradientAppBar(context, 'Privacy Policy'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Markdown(
          data: markdownContent,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: const TextStyle(fontSize: 16, fontFamily: 'Proxima'),
            h1: const TextStyle(fontFamily: 'Proxima', fontSize: 24, fontWeight: FontWeight.bold),
            h2: const TextStyle(fontFamily: 'Proxima', fontSize: 22, fontWeight: FontWeight.bold),
            h3: const TextStyle(fontFamily: 'Proxima', fontSize: 20, fontWeight: FontWeight.bold),
            listBullet: const TextStyle(fontFamily: 'Proxima', fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class HelpSupportPage extends StatelessWidget {
  // Markdown content for Help & Support
  final String markdownContent = """
# Help & Support

Welcome to Reportify! We’re here to help you make the most of our platform and ensure a smooth experience. If you have any questions or encounter any issues, check out the resources below.

## Frequently Asked Questions (FAQs)

**1. How do I report an issue?**  
To report an issue:  
- Open the app and navigate to the "Report" section.  
- Select the appropriate category (e.g., accident, theft, public safety, natural disaster, etc.).  
- Fill in the details and upload any relevant photos.  
- Submit your report, and it will be forwarded to the relevant authorities.

**2. How can I track my report status?**  
Reports can be seen in the "User Home" section. Each category is available, and you can press on it to view reports.

**3. What should I do in case of an emergency?**  
Use the SOS Alert feature to immediately notify emergency services. If it’s a critical situation, call local emergency numbers provided in the "Emergency Contacts" section.

**4. Can I edit or delete a report after submitting it?**  
Reports cannot be edited once submitted to maintain data accuracy. Users can delete their own reports from the "User Home" section.

**5. How do I report a lost or found item?**  
Go to the "Lost & Found" section. Enter the details of the lost or found item, along with any pictures. Submit the post, and other users can assist in locating the item.

**6. How do I use the blood donation feature?**  
Navigate to the "Blood Donation" section. View active donation requests or post a request for blood. If you are willing to donate, click on the request and follow the instructions.

**7. How can I stay updated on alerts and local events?**  
Enable notifications in the app settings to receive updates on emergencies, local events, and offers. Visit the "Alerts" or "Events" section for the latest updates.

**8. How do I contact customer support?**  
If you need further assistance, you can reach us through:  
Email: projectmail155@gmail.com

## Technical Support

If you experience any technical issues, such as login problems, app crashes, or bugs, try the following steps:
- Restart the app and try again.
- Check for updates in your app store to ensure you’re using the latest version.
- Clear cache/data from app settings (Android users only).
- Reinstall the app if the issue persists.

If the problem continues, contact our support team with a detailed description of the issue.

## Community Guidelines

To maintain a safe and responsible community, please:
- Report issues accurately and truthfully.
- Avoid posting false or misleading reports.
- Respect other users and refrain from any offensive language.

## Feedback & Suggestions

We’re constantly improving Reportify! If you have any suggestions or feedback, feel free to reach out via the "Feedback" section in the app.

Thank you for using Reportify to make your community a safer place!
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildGradientAppBar(context, 'Help & Support'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Markdown(
          data: markdownContent,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: const TextStyle(fontSize: 16, fontFamily: 'Proxima'),
            h1: const TextStyle(fontFamily: 'Proxima', fontSize: 24, fontWeight: FontWeight.bold),
            h2: const TextStyle(fontFamily: 'Proxima', fontSize: 22, fontWeight: FontWeight.bold),
            h3: const TextStyle(fontFamily: 'Proxima', fontSize: 20, fontWeight: FontWeight.bold),
            listBullet: const TextStyle(fontFamily: 'Proxima', fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class FeedbacckPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // When tapped from the InfoPage, navigates here.
    return Scaffold(
      appBar: buildGradientAppBar(context, 'Feedback'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Feedback Content Here',
          style: const TextStyle(fontSize: 16, fontFamily: 'Proxima'),
        ),
      ),
    );
  }
}
