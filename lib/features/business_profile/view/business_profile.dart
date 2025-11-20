import 'package:creatoo/core.dart';
import 'package:creatoo/features/business_profile/model/business_profile_response.dart';

import '../view_model/business_profile_view_model.dart';

class BusinessProfileView extends StatefulWidget {
  const BusinessProfileView({super.key});

  @override
  State<BusinessProfileView> createState() => _BusinessProfileViewState();
}

class _BusinessProfileViewState extends State<BusinessProfileView> {
  @override
  void initState() {
    super.initState();
    BusinessProfileViewModel businessProfileViewModel = Provider.of<BusinessProfileViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      businessProfileViewModel.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    BusinessProfileViewModel businessProfileViewModel = Provider.of<BusinessProfileViewModel>(context);

    switch (businessProfileViewModel.profileResponse.status) {
      case Status.loading:
        return const AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: businessProfileViewModel.profileResponse.message.toString());
      case Status.completed:
        var item = businessProfileViewModel.profileResponse.data!.data!;
        return Scaffold(
          body: SafeArea(
            child: Container(
              width: SizeConfig.screenWidth,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50.h,
                    foregroundImage: NetworkImage(
                      '$baseUrl${item.businessImage}',
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    '${businessProfileViewModel.profileResponse.data!.data!.businessName}',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'GSTIN: ${item.gstNumber}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  buildProfileContainer(item),
                  SizedBox(height: 10.h),
                  buildUserContainer(item, disableLeadingIcon: true),
                ],
              ),
            ),
          ),
        );
      default:
        return const AppNoDataWidget();
    }
  }

  Container buildProfileContainer(Data item, {bool disableLeadingIcon = false}) {
    return Container(
      width: SizeConfig.screenWidth,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              !disableLeadingIcon ? Icon(Icons.account_circle) : SizedBox.shrink(),
              Text('${item.businessName}'),
              Icon(Icons.edit),
            ],
          ),
          SizedBox(height: 10.h),
          Text('${item.businessArea}'),
          SizedBox(
            height: 10.h,
          ),
          Text(
            '${item.businessSiteUrl}',
            style: TextStyle(),
          ),
        ],
      ),
    );
  }

  Container buildUserContainer(Data item, {bool disableLeadingIcon = false}) {
    return Container(
      width: SizeConfig.screenWidth,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              !disableLeadingIcon ? Icon(Icons.account_circle) : SizedBox.shrink(),
              Text('${item.businessFullname}'),
              Icon(Icons.edit),
            ],
          ),
          SizedBox(height: 10.h),
          Text('${item.businessDesignation}'),
          SizedBox(height: 10.h),
          Text('${item.businessArea}'),
          SizedBox(
            height: 10.h,
          ),
          Text(
            '${item.businessEmail}',
            style: TextStyle(),
          ),
          SizedBox(
            height: 10.h,
          ),
          Text(
            '${item.businessMobile}',
            style: TextStyle(),
          ),
        ],
      ),
    );
  }
}
