import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotEnoughHeartsModal extends StatelessWidget {
  final VoidCallback? onGetTickets;
  final VoidCallback? onOk;

  const NotEnoughHeartsModal({
    Key? key,
    this.onGetTickets,
    this.onOk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Not Enough Hearts',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8539A8),
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // Heart Icon
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite,
                color: Colors.white,
                size: 40.sp,
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // Message
            Text(
              "You don't have enough Hearts to\ncontinue to play.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Color(0xFF8539A8),
                height: 1.4,
              ),
            ),
            
            SizedBox(height: 30.h),
            
            // Buttons Row
            Row(
              children: [
                // Get Tickets Button
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: onGetTickets,
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: Color(0xFF8539A8),
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Center(
                        child: Text(
                          'Get Tickets',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: 15.w),
                
                // OK Button
                Expanded(
                  child: GestureDetector(
                    onTap: onOk ?? () => Navigator.of(context).pop(),
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Center(
                        child: Text(
                          'OK',
                          style: TextStyle(
                            color: Color(0xFF8539A8),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// Function to show the modal
void showNotEnoughHeartsModal(BuildContext context, {
  VoidCallback? onGetTickets,
  VoidCallback? onOk,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54, // Semi-transparent background
    builder: (BuildContext context) {
      return NotEnoughHeartsModal(
        onGetTickets: onGetTickets,
        onOk: onOk,
      );
    },
  );
}