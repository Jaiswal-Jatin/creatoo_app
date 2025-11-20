import '../../../core.dart';
import '../../../widgets/app_text_widget.dart';
import '../view_model/search_view_model.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late SearchViewModel viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<SearchViewModel>(context, listen: false);
    viewModel.init(Constants.businessUser);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        viewModel.loadMoreBusinessUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<SearchViewModel>(context);

    switch (viewModel.searchResponse.status) {
      case Status.loading:
        return AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.searchResponse.message.toString());
      case Status.completed:
        return _buildBody();
      default:
        return AppNoDataWidget();
    }
  }

  Widget _buildBody() {
    return AppScaffold(
      isSafe: false,
      appBar: AppBarWidget(
        title: "Search Profile",
        disableLeadingButton: true,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                buildSearchField(viewModel),
              ],
            ),
          ),
          Expanded(
            child: (viewModel.businessSearchList == null || viewModel.businessSearchList!.isEmpty)
                ? Center(child: AppTextWidget(text: "No Businesses to show"))
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    itemCount: viewModel.businessSearchList!.length + (viewModel.hasMoreData ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == viewModel.businessSearchList!.length) {
                        return viewModel.isLoadingMore
                            ? Center(
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: CircularProgressIndicator(color: AppColor.primary),
                                ),
                              )
                            : SizedBox.shrink(); // Prevents unnecessary widget rendering
                      }
                      return _buildBusinessDetailsCard(
                          businessId: viewModel.businessSearchList?[index].id ?? 0,
                          businessName: viewModel.businessSearchList?[index].businessName ?? '',
                          imageUrl: viewModel.businessSearchList?[index].businessImage ?? '',
                          address: viewModel.businessSearchList?[index].businessArea ?? '',
                          ratings: viewModel.businessSearchList?[index].avgExperience,
                          priceRange: viewModel.businessSearchList?[index].pricingRangeText ?? '',
                          discount: (viewModel.businessSearchList?[index].set_first_time_discount as num?)?.toInt());
                    },
                  ),
          ),
        ],
      ),
    );
  }

  SizedBox buildSearchField(SearchViewModel viewModel) {
    return SizedBox(
      height: 50.h,
      child: TextFormField(
        controller: viewModel.searchController,
        onChanged: (value) {
          viewModel.onSearchTextChanged(value);
        },
        decoration: InputDecoration(
          fillColor: AppColor.white,
          filled: true,
          hintText: "Search by name...",
          hintStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
          prefixIcon: Padding(
            padding: EdgeInsets.all(10),
            child: SvgPicture.asset(
              AppIcon.search,
              height: 15.h,
              width: 15.h,
              colorFilter: ColorFilter.mode(Color(0xFF909090), BlendMode.srcIn),
            ),
          ),
          suffixIcon: viewModel.searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColor.grey),
                  onPressed: () {
                    viewModel.searchController.clear();
                    viewModel.onSearchTextChanged("");
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Color(0xFFE8ECF4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Color(0xFFE8ECF4)),
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessDetailsCard({
    required int businessId,
    required String? imageUrl,
    required String? businessName,
    required String? address,
    required String? ratings,
    required String? priceRange,
    required int? discount,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, RoutesName.businessDescriptionView, arguments: businessId);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white, // White background for the image area
              ),
              child: AppImageWidget(
                imageUrl: imageUrl ?? '',
                height: 300, // Increased height as requested
                width: double.maxFinite,
                borderRadius: 16,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 120, // Adjust height of the gradient as needed
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8), // Dark black shadow
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: IntrinsicHeight(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                  ),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: AppTextWidget(
                                text: businessName,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                softWrap: true,
                                maxLines: 1,
                                textOverflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: 18.w,
                            ),
                            if (ratings != null)
                              Container(
                                width: 50,
                                height: 25,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColor.rating),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      AppTextWidget(
                                        text: ratings,
                                        fontSize: 12,
                                        color: AppColor.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: AppColor.white,
                                        size: 12,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 50,
                                height: 25,
                              )
                          ],
                        ),
                      ),
                      if ((priceRange != null && priceRange.isNotEmpty) || (address != null && address.isNotEmpty))
                        Column(
                          children: [
                            SizedBox(height: 6),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.sizeOf(context).width * 0.5,
                                    ),
                                    child: AppTextWidget(
                                      text: address,
                                      fontSize: 15,
                                      textOverflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  AppTextWidget(
                                    text: '$priceRange',
                                    fontSize: 15,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      if (discount != null && discount > 0)
                        Column(
                          children: [
                            SizedBox(
                              height: 6,
                            ),
                            AppTextWidget(
                              text: 'Get ${discount}% Off',
                              fontSize: 15,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
