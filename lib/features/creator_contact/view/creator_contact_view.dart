import '../../../core.dart';
import '../model/creator_contact_response.dart';
import '../view_model/creator_contact_view_model.dart';

class CreatorContactView extends StatefulWidget {
  final int postId;

  const CreatorContactView({super.key, required this.postId});

  @override
  State<CreatorContactView> createState() => _CreatorContactViewState();
}

class _CreatorContactViewState extends State<CreatorContactView> {
  late CreatorContactViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<CreatorContactViewModel>(context, listen: false);
    viewModel.fetchCreatorContactList(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<CreatorContactViewModel>(context);
    switch (viewModel.apiResponse.status) {
      case Status.loading:
        return const AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(
          message: viewModel.apiResponse.message.toString(),
        );
      case Status.completed:
        List<CreatorContact> creatorList = viewModel.apiResponse.data!.data!;
        return AppScaffold(
          appBar: AppBarWidget(
            title: "Post ID#${widget.postId}",
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: creatorList.isNotEmpty,
                replacement: Container(
                  height: SizeConfig.screenHeight / 2,
                  width: SizeConfig.screenWidth,
                  alignment: Alignment.center,
                  child: Text('No creator data!'),
                ),
                child: Expanded(
                  child: ListView.builder(
                    itemCount: creatorList.length,
                    itemBuilder: (context, index) {
                      CreatorContact item = creatorList[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: buildContactCard(
                          name: "${item.name}",
                          username: "${item.instagramUsername}",
                          contact: "${item.mobile}",
                          email: "${item.email}",
                          address: "${item.address}",
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return const AppNoDataWidget();
    }
  }

  Widget buildContactCard({
    required String name,
    required String username,
    required String contact,
    required String email,
    required String address,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColor.lightGrey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            child: Text(
              "Creator Details",
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFF343434),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.person, color: Colors.black),
              SizedBox(width: 15),
              Text(
                name,
                style: TextStyle(fontSize: 14.0),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              SvgPicture.asset(
                "assets/icons/instagram.svg",
                height: 20.h,
              ),
              SizedBox(width: 15),
              Text(
                username,
                style: TextStyle(fontSize: 14.0, color: Colors.blue),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.phone, color: Colors.green),
              SizedBox(width: 15),
              Text(
                contact,
                style: TextStyle(fontSize: 14.0),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.email, color: Colors.orange),
              SizedBox(width: 15),
              Text(
                email,
                style: TextStyle(fontSize: 14.0),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: Colors.red),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(fontSize: 14.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
