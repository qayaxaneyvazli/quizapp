import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TopBar extends StatefulWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  // Track expanded state of menu items
  final Map<String, bool> _expandedItems = {
    'Profile': false,
    'Quiz': false,
    'Rewards': false,
  };

  void _toggleExpanded(String key) {
    setState(() {
      _expandedItems[key] = !(_expandedItems[key] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width to determine if we're on a tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    // Adjust drawer width based on device type
    // For tablets, make drawer narrower to use screen space more efficiently
    final drawerWidth = isTablet ? screenWidth * 0.3 : screenWidth * 0.75;
    
    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        backgroundColor: const Color(0xFF4A7DFF),
        child: SafeArea(
          child: Column(
            children: [
              // User profile section - more compact on tablet
              Padding(
                padding: EdgeInsets.all(isTablet ? 16.r : 16.r),
                child: Row(
                  children: [
                    Container(
                      width: isTablet ? 56.r : 60.r,
                      height: isTablet ? 56.r : 60.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE8E4FF),
                        border: Border.all(color: Colors.white, width: isTablet ? 2.r : 2.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(isTablet ? 28.r : 30.r),
                        child: Image.asset(
                          'assets/images/avatar.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, size: isTablet ? 36.r : 40.r, color: Colors.grey);
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 12.w : 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Melikmemmed",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 11.sp : 18.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 8.w : 8.w, 
                              vertical: isTablet ? 3.h : 4.h
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(isTablet ? 10.r : 12.r),
                            ),
                            child: Text(
                              "Premium",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: isTablet ? 7.sp : 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Divider
              Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
              
              // Expandable menu items
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile expandable section
                      _buildExpandableSection(
                        title: 'Profile',
                        icon: Icons.person,
                        isTablet: isTablet,
                        children: [
                          _buildSubMenuItem(
                            title: 'View Profile',
                            isTablet: isTablet,
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to profile page
                            },
                          ),
                          _buildSubMenuItem(
                            title: 'Edit Profile',
                            isTablet: isTablet,
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to edit profile page
                            },
                          ),
                          _buildSubMenuItem(
                            title: 'Change Avatar',
                            isTablet: isTablet,
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to change avatar page
                            },
                          ),
                        ],
                      ),
                      
                      // Quiz expandable section
                      _buildExpandableSection(
                        title: 'Quiz',
                        icon: Icons.casino,
                        isTablet: isTablet,
                        children: [
                          _buildSubMenuItem(
                            title: 'Quiz History',
                            isTablet: isTablet,
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to quiz history
                            },
                          ),
                          _buildSubMenuItem(
                            title: 'Leaderboard',
                            isTablet: isTablet,
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to leaderboard
                            },
                          ),
                          _buildSubMenuItem(
                            title: 'Achievements',
                            isTablet: isTablet,
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to achievements
                            },
                          ),
                        ],
                      ),
                      
                      // Rewards expandable section
                      _buildExpandableSection(
                        title: 'Rewards',
                        icon: Icons.card_giftcard,
                        isTablet: isTablet,
                        children: [
                          _buildSubMenuItem(
                            title: 'Available Rewards',
                            isTablet: isTablet,
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to available rewards
                            },
                          ),
                          _buildSubMenuItem(
                            title: 'My Purchases',
                            isTablet: isTablet,
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to purchases
                            },
                          ),
                          _buildSubMenuItem(
                            title: 'Redeem Code',
                            isTablet: isTablet,
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to redeem code
                            },
                          ),
                        ],
                      ),
                      
                      // Non-expandable items
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        title: "Help & Support",
                        isTablet: isTablet,
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to help and support
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.info_outline,
                        title: "About Us",
                        isTablet: isTablet,
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to about us
                        },
                      ),
                      
                      // Statistics section - more compact on tablet
                      Padding(
                        padding: EdgeInsets.all(isTablet ? 16.r : 16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Statistics",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 11.sp : 18.sp,
                              ),
                            ),
                            SizedBox(height: isTablet ? 16.h : 16.h),
                            _buildStatItem(
                              icon: Icons.check_circle,
                              title: "Total Questions",
                              value: "1,234",
                              isTablet: isTablet,
                            ),
                            SizedBox(height: isTablet ? 12.h : 12.h),
                            _buildStatItem(
                              icon: Icons.emoji_events,
                              title: "Quiz Won",
                              value: "56",
                              isTablet: isTablet,
                            ),
                            SizedBox(height: isTablet ? 12.h : 12.h),
                            _buildStatItem(
                              icon: Icons.star,
                              title: "Accuracy",
                              value: "76%",
                              isTablet: isTablet,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom buttons - more compact on tablet
              Padding(
                padding: EdgeInsets.all(isTablet ? 16.r : 16.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to settings
                      },
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 10.r : 12.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(isTablet ? 8.r : 8.r),
                        ),
                        child: Icon(Icons.settings, color: Colors.white, size: isTablet ? 24.r : 24.r),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        // Logout action
                      },
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 10.r : 12.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(isTablet ? 8.r : 8.r),
                        ),
                        child: Icon(Icons.exit_to_app, color: Colors.white, size: isTablet ? 24.r : 24.r),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isTablet,
  }) {
    final isExpanded = _expandedItems[title] ?? false;
    
    return Column(
      children: [
        ListTile(
          dense: isTablet, // Make list tiles more compact on tablet
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16.w : 16.w,
            vertical: isTablet ? 2.h : 4.h,
          ),
          leading: Icon(
            icon, 
            color: Colors.white, 
            size: isTablet ? 24.r : 24.r
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 10.sp : 16.sp,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Colors.white,
            size: isTablet ? 20.r : 24.r,
          ),
          onTap: () => _toggleExpanded(title),
        ),
        if (isExpanded)
          Column(children: children),
      ],
    );
  }

  Widget _buildSubMenuItem({
    required String title,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return ListTile(
      dense: isTablet, // Make submenu items more compact on tablet
      contentPadding: EdgeInsets.only(
        left: isTablet ? 28.w : 56.w, 
        right: isTablet ? 16.w : 16.w,
        top: isTablet ? 0.h : 2.h,
        bottom: isTablet ? 0.h : 2.h,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: isTablet ? 10.sp : 14.sp,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return ListTile(
      dense: isTablet, // Make menu items more compact on tablet
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16.w : 16.w,
        vertical: isTablet ? 2.h : 4.h,
      ),
      leading: Icon(
        icon, 
        color: Colors.white, 
        size: isTablet ? 24.r : 24.r
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 10.sp : 16.sp,
        ),
      ),
      // trailing: Icon(
      //   Icons.arrow_forward_ios, 
      //   color: Colors.white, 
      //   size: isTablet ? 14.r : 16.r
      // ),
      onTap: onTap,
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required bool isTablet,
  }) {
    return Row(
      children: [
        Icon(
          icon, 
          color: Colors.amber, 
          size: isTablet ? 18.r : 20.r
        ),
        SizedBox(width: isTablet ? 2.w : 8.w),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 10.sp : 14.sp,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 10.sp : 14.sp,
          ),
        ),
      ],
    );
  }
}