import '../../../core.dart';
import '../view_model/search_view_model.dart';

class SearchBusinessView extends StatefulWidget {
  @override
  State<SearchBusinessView> createState() => _SearchBusinessViewState();
}

class _SearchBusinessViewState extends State<SearchBusinessView> {
  @override
  void initState() {
    super.initState();
    final SearchViewModel searchViewModel = Provider.of<SearchViewModel>(context, listen: false);
    searchViewModel.init(Constants.businessUser);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final SearchViewModel viewModel = Provider.of<SearchViewModel>(context);
    switch (viewModel.searchResponse.status) {
      case Status.loading:
        return Container(
          height: SizeConfig.screenHeight / 2,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case Status.error:
        return AppErrorWidget(
          message: viewModel.searchResponse.message.toString(),
        );
      case Status.completed:
        return Expanded(
          child: Visibility(
            visible: (viewModel.searchResponse.data!.data != null && viewModel.searchResponse.data!.data!.isNotEmpty),
            replacement: Center(child: Text('Businesses not found')),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: viewModel.searchResponse.data!.data!.length,
              itemBuilder: (context, index) {
                var item = viewModel.searchResponse.data!.data![index];
                return Container(
                  height: 85.h,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), color: AppColor.white, border: Border.all(color: AppColor.lightGrey)),
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AppImageWidget(
                        height: 50.h,
                        width: 50.h,
                        imageUrl: item.businessImage!,
                      ),
                    ),
                    title: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${item.businessName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      default:
        return AppNoDataWidget();
    }
  }
}
