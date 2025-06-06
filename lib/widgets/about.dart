import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutWidget extends StatelessWidget {
  const AboutWidget({super.key});

  Widget _buildBullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.4,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paragraph(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 16,
          height: 1.5,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _header(String text, {double size = 32}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, top: 24),
      child: Align(
        alignment: Alignment.center,
        child: Semantics(
          header: true,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.epilogue(
              fontSize: size,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _faqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 8, bottom: 8),
        title: Text(
          question,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.5,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 750),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header('About Narrativva Status Checker'),
              _paragraph(
                context,
                'Narrativva Status Checker is a simple yet powerful tool designed for monitoring the uptime and health of websites and applications. While it was built first and foremost as an internal solution for overseeing the core systems behind Narrativva and Narrativva Labs, we\'re making it available for anyone who needs a straightforward status dashboard—no unnecessary signups or complexity.',
              ),
              _header('Why Use Narrativva Status Checker?', size: 26),
              _paragraph(
                context,
                'Website availability and stability are critical for any digital project. Outages cost you visitors, reputation, and business opportunities. That\'s why Narrativva Status Checker was created: to keep a constant eye on the status of all our Narrativva and Narrativva Labs projects, and to share this capability with our community.',
              ),
              _buildBullet(context, 'Instantly see the live status of all Narrativva and Narrativva Labs systems, plus your own websites.'),
              _buildBullet(context, 'A clear, visual dashboard shows which pages are online at a glance.'),
              _buildBullet(context, 'Automated checks run every 15 minutes, so you\'re never in the dark about downtime or performance issues.'),
              _buildBullet(context, 'Discord notifications let you respond quickly to incidents.'),
              _buildBullet(context, 'The system is especially optimized for Narrativva projects, but is also perfect for freelancers, small teams, and agencies.'),
              _header('Key Features', size: 26),
              _buildBullet(context, 'Live Monitoring: Automatic checks run every 15 minutes, ensuring your sites are always covered.'),
              _buildBullet(context, 'Add Projects in Seconds: Quickly add any website or app to your dashboard.'),
              _buildBullet(context, 'Up to 10 Projects per User: To keep things fast and focused, each user can add up to ten projects for monitoring.'),
              _buildBullet(context, 'Clear Status Indicators: Modern, color-coded dashboard (green for online, gray for offline).'),
              _buildBullet(context, 'Discord Integration: Get instant alerts on your Discord server when a site goes down or comes back online.'),
              _buildBullet(context, 'Privacy-First: We never track unnecessary data—your site info stays yours.'),
              _buildBullet(context, 'Built by Narrativva Labs: Developed in-house by the Narrativva Labs team, now available for everyone.'),
              _header('About Narrativva Labs', size: 26),
              _paragraph(
                context,
                'Narrativva Labs is the innovation hub of Narrativva, where we experiment, prototype, and release new digital tools and web applications. Status Checker is our primary internal monitoring platform—it\'s what we rely on to keep Narrativva\'s systems stable and reliable. By sharing it, we hope to inspire others and help anyone looking for a simple status monitoring solution.',
              ),
              _header('Getting Started', size: 26),
              _buildBullet(context, 'Add your websites or applications to the dashboard (up to 10 per account).'),
              _buildBullet(context, 'Monitor live status in an intuitive, clean dashboard.'),
              _buildBullet(context, 'Set up Discord notifications for real-time incident alerts.'),
              _buildBullet(context, 'Completely free—no signups or credit cards required.'),
              _header('FAQ', size: 26),
              _faqItem(
                context,
                question: 'Is Narrativva Status Checker free?',
                answer: "Yes, it's 100% free to use.",
              ),
              _faqItem(
                context,
                question: 'How often does it check my websites?',
                answer: 'Checks are performed automatically every 15 minutes.',
              ),
              _faqItem(
                context,
                question: 'How many projects can I add?',
                answer: 'Each user can monitor up to 10 projects at once.',
              ),
              _faqItem(
                context,
                question: 'Where can I find more Narrativva Labs tools?',
                answer: 'Visit labs.narrativva.com for the latest projects.',
              ),
              _paragraph(
                context,
                'Narrativva Status Checker is our core monitoring solution for all Narrativva and Narrativva Labs systems, now open to anyone who wants to keep their sites online, available, and secure.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

