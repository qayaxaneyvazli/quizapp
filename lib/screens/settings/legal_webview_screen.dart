import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class LegalWebViewScreen extends ConsumerStatefulWidget {
  final String url;
  final String title;

  const LegalWebViewScreen({
    Key? key,
    required this.url,
    required this.title,
  }) : super(key: key);

  @override
  ConsumerState<LegalWebViewScreen> createState() => _LegalWebViewScreenState();
}

class _LegalWebViewScreenState extends ConsumerState<LegalWebViewScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _launchUrl();
  }

  Future<void> _launchUrl() async {
    try {
      final Uri url = Uri.parse(widget.url);
      
      // Try to launch URL
      final bool canLaunch = await canLaunchUrl(url);
      if (canLaunch) {
        final bool launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        
        if (launched) {
          // Close this screen after launching the URL
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          _showError('Failed to launch URL. Please try again.');
        }
      } else {
        _showError('No app found to open this URL. Please check if you have a browser installed.');
      }
    } catch (e) {
      print('URL Launcher Error: $e');
      _showError('Unable to open link. Please try again later.');
    }
  }

  void _showError(String message) {
    setState(() {
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyUrlToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('URL copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? theme.colorScheme.surface : Color(0xFF6A1B9A),
        title: Text(
          widget.title,
          style: TextStyle(
            color: isDarkMode ? theme.colorScheme.onSurface : Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back_icon.svg',
            width: 40,
            height: 40,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Opening ${widget.title}...',
                    style: theme.textTheme.bodyLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This will open in your browser',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Failed to open page',
                    style: theme.textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Could not open the requested page. Please check your internet connection and try again.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Go Back'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                          });
                          _launchUrl();
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: _copyUrlToClipboard,
                    child: Text('Copy URL to Clipboard'),
                  ),
                ],
              ),
            ),
    );
  }
}