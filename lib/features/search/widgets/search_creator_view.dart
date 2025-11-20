import 'package:creatoo/features/search/model/search_creator_model.dart';

import '../../../core.dart';
import '../view_model/search_view_model.dart';

class SearchCreatorView extends StatefulWidget {
  @override
  State<SearchCreatorView> createState() => _SearchCreatorViewState();
}

class _SearchCreatorViewState extends State<SearchCreatorView> {
  @override
  void initState() {
    super.initState();
    final SearchViewModel searchViewModel =
        Provider.of<SearchViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      searchViewModel.init(Constants.creatorUser);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final SearchViewModel viewModel = Provider.of<SearchViewModel>(context);
    switch (viewModel.creatorResponse.status) {
      case Status.loading:
        return Container(
          height: SizeConfig.screenHeight / 2,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      case Status.error:
        return Center(
            child: Text(viewModel.creatorResponse.message.toString()));
      case Status.completed:
        return Expanded(
          child: Visibility(
            visible: (viewModel.creatorResponse.data!.data != null &&
                viewModel.creatorResponse.data!.data!.isNotEmpty),
            replacement: Center(child: Text('Creators not found')),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: viewModel.creatorResponse.data!.data!.length,
              itemBuilder: (context, index) {
                var item = viewModel.creatorResponse.data!.data![index];
                return SearchCard(item: item);
              },
            ),
          ),
        );
      default:
        return const AppNoDataWidget();
    }
  }
}

class SearchCard extends StatelessWidget {
  const SearchCard({
    super.key,
    required this.item,
  });

  final Data item;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 85.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColor.white,
        border: Border.all(
          color: AppColor.lightGrey,
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: AppImageWidget(
              height: 50.h,
              width: 50.h,
              imageUrl: item.userImage!,
            ),
          ),
          SizedBox(width: 10.h),
          Container(
            width: MediaQuery.of(context).size.width - 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    item.name ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Visibility(
                  visible: item.instagramUsername == null ? false : true,
                  child: Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      item.instagramUsername ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(
                        fontSize: 14.sp,
                      ).copyWith(color: Colors.blue),
                    ),
                  ),
                ),
                Visibility(
                  visible: item.bio == null ? false : true,
                  child: Container(
                    width: SizeConfig.screenWidth - 150,
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      item.bio ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(
                        fontSize: 12.sp,
                      ).copyWith(color: AppColor.darkGrey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
