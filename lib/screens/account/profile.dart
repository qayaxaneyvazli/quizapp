import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_flags/country_flags.dart';
import 'package:quiz_app/providers/user/user_provider.dart';



class AccountPage extends ConsumerWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    
    // Get screen dimensions to determine if we're on a tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B8DEF),
        elevation: 0,
        title: Text(
          'Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 20.sp : 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Stats section at top
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            color: const Color(0xFF5B8DEF),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem(
                  icon: Icons.star,
                  value: userProfile.stars.toString(),
                  color: Colors.amber,
                  isTablet: isTablet,
                ),
                SizedBox(width: isTablet ? 32.w : 40.w),
                _buildStatItem(
                  icon: Icons.favorite,
                  value: userProfile.hearts.toString(),
                  color: Colors.red,
                  isTablet: isTablet,
                ),
                SizedBox(width: isTablet ? 32.w : 40.w),
                _buildStatItem(
                  icon: Icons.monetization_on,
                  value: userProfile.coins.toString(),
                  color: Colors.amber,
                  isTablet: isTablet,
                ),
              ],
            ),
          ),
          
          // Profile Items
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    // Avatar
                    _buildProfileItem(
                      child: CircleAvatar(
                        radius: isTablet ? 40.r : 50.r,
                        backgroundColor: const Color(0xFFEFE5FF),
                        backgroundImage: userProfile.avatarUrl.isNotEmpty
                            ? NetworkImage(userProfile.avatarUrl)
                            : null,
                        child: userProfile.avatarUrl.isEmpty
                            ? Icon(Icons.person, size: isTablet ? 40.r : 50.r, color: Colors.grey)
                            : null,
                      ),
                      onEdit: () {
                        // Avatar selection dialog
                      },
                      isTablet: isTablet,
                    ),
                    SizedBox(height: 20.h),
                    
                    // Country flag
                    _buildProfileItem(
                      child: Container(
                        width: isTablet ? 80.r : 100.r,
                        height: isTablet ? 80.r : 100.r,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: CountryFlag.fromCountryCode(
                          userProfile.countryCode,
                          height: isTablet ? 80.r : 100.r,
                          width: isTablet ? 80.r : 100.r,
                          shape: const Circle(),
                        ),
                      ),
                      onEdit: () {
                        // Flag selection dialog
                      },
                      isTablet: isTablet,
                    ),
                    SizedBox(height: 20.h),
                    
                    // Username field
                    _buildProfileItem(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter your username',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: isTablet ? 14.sp : 16.sp,
                          ),
                          onChanged: (value) {
                            ref.read(userProfileProvider.notifier).updateUsername(value);
                          },
                        ),
                      ),
                      onEdit: () {
                        // Focus username field
                      },
                      isTablet: isTablet,
                    ),
                    SizedBox(height: 20.h),
                    
                    // User ID with copy button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        children: [
                          Text(
                            'ID: ${userProfile.userId}',
                            style: TextStyle(
                              fontSize: isTablet ? 14.sp : 16.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.copy, size: isTablet ? 20.r : 24.r),
                            onPressed: () {
                              // Copy ID to clipboard
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('ID copied to clipboard')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon, 
    required String value, 
    required Color color,
    required bool isTablet,
  }) {
    return Column(
      children: [
        Container(
          width: isTablet ? 40.r : 50.r,
          height: isTablet ? 40.r : 50.r,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: isTablet ? 20.r : 25.r,
            ),
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 16.sp : 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

 Widget _buildProfileItem({
  required Widget child, 
  required VoidCallback onEdit,
  required bool isTablet,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Colors.grey[300]!,
          width: 1.h,
        ),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: child,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.edit,
            color: Colors.black,
            size: isTablet ? 20.r : 24.r,
          ),
          onPressed: onEdit,
        ),
      ],
    ),
  );
}
}