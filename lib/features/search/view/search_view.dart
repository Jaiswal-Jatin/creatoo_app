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
    print("SearchView: initState called");
    viewModel = Provider.of<SearchViewModel>(context, listen: false);
    viewModel.init(Constants.businessUser);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        viewModel.loadMoreBusinessUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<SearchViewModel>(context);
    print("SearchView: build called, status: ${viewModel.searchResponse.status}");

    switch (viewModel.searchResponse.status) {
      case Status.loading:
        print("SearchView: Status.loading");
        return AppLoadingWidget();
      case Status.error:
        print("SearchView: Status.error, message: ${viewModel.searchResponse.message}");
        return AppErrorWidget(
            message: viewModel.searchResponse.message.toString());
      case Status.completed:
        print("SearchView: Status.completed");
        return _buildBody();
      default:
        print("SearchView: Status.default (AppNoDataWidget)");
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
            child: (viewModel.businessSearchList == null ||
                    viewModel.businessSearchList!.isEmpty)
                ? Center(child: AppTextWidget(text: "No Businesses to show"))
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    itemCount: viewModel.businessSearchList!.length +
                        (viewModel.hasMoreData ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == viewModel.businessSearchList!.length) {
                        return viewModel.isLoadingMore
                            ? Center(
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: CircularProgressIndicator(
                                      color: AppColor.primary),
                                ),
                              )
                            : SizedBox
                                .shrink(); // Prevents unnecessary widget rendering
                      }
                      return _buildBusinessDetailsCard(
                          businessId:
                              viewModel.businessSearchList?[index].id ?? 0,
                          businessName: viewModel
                                  .businessSearchList?[index].businessName ??
                              '',
                          imageUrl: viewModel
                                  .businessSearchList?[index].businessImage ??
                              '',
                          address: viewModel
                                  .businessSearchList?[index].businessArea ??
                              '',
                          ratings: viewModel
                              .businessSearchList?[index].avgExperience,
                          priceRange: viewModel.businessSearchList?[index]
                                  .pricingRangeText ??
                              '',
                          discount: (viewModel.businessSearchList?[index]
                                  .set_first_time_discount as num?)
                              ?.toInt());
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
        onFieldSubmitted: (value) { // Call searchUser only when submitted
          viewModel.searchUser(searchQuery: value);
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
                    viewModel.restoreOriginalList(); // Call restoreOriginalList on clear
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
    final h = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints
    final isVerySmall = h < 600;
    final isSmall = h < 700 && !isVerySmall;
    final isMedium = h >= 700 && h < 850;
    
    // Responsive values
    double cardHeight;
    double gradientHeight;
    double discountHeight;
    double titleFontSize;
    double addressFontSize;
    double discountFontSize;
    double cardPadding;
    double cardMargin;
    double ratingWidth;
    double ratingHeight;
    
    if (isVerySmall) {
      cardHeight = 200;
      gradientHeight = 80;
      discountHeight = 30;
      titleFontSize = 13;
      addressFontSize = 12;
      discountFontSize = 11;
      cardPadding = 6;
      cardMargin = 6;
      ratingWidth = 42;
      ratingHeight = 22;
    } else if (isSmall) {
      cardHeight = 230;
      gradientHeight = 90;
      discountHeight = 34;
      titleFontSize = 14;
      addressFontSize = 13;
      discountFontSize = 12;
      cardPadding = 7;
      cardMargin = 7;
      ratingWidth = 45;
      ratingHeight = 23;
    } else if (isMedium) {
      cardHeight = 260;
      gradientHeight = 100;
      discountHeight = 36;
      titleFontSize = 15;
      addressFontSize = 14;
      discountFontSize = 13;
      cardPadding = 8;
      cardMargin = 8;
      ratingWidth = 48;
      ratingHeight = 24;
    } else {
      cardHeight = 300;
      gradientHeight = 120;
      discountHeight = 40;
      titleFontSize = 16;
      addressFontSize = 15;
      discountFontSize = 14;
      cardPadding = 8;
      cardMargin = 8;
      ratingWidth = 50;
      ratingHeight = 25;
    }
    
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, RoutesName.businessDescriptionView,
            arguments: businessId);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: cardMargin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: AppImageWidget(
                imageUrl: imageUrl ?? '',
                height: cardHeight,
                width: double.maxFinite,
                borderRadius: 16,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: gradientHeight,
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
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: cardPadding,
              left: 0,
              right: 0,
              child: IntrinsicHeight(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: cardPadding),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                  ),
                  padding: EdgeInsets.all(cardPadding),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (discount != null && discount > 0)
                        Container(
                          height: discountHeight,
                          width: double.maxFinite,
                          margin: EdgeInsets.only(bottom: cardPadding),
                          padding: EdgeInsets.symmetric(
                              horizontal: cardPadding * 2, vertical: cardPadding * 0.6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                AppColor.kPrimary,
                                AppColor.kPrimary,
                                Colors.transparent,
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppTextWidget(
                                text: "Flat ${discount}% OFF + 3 more",
                                fontSize: discountFontSize,
                                color: AppColor.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                        ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: AppTextWidget(
                                text: businessName,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w600,
                                softWrap: true,
                                maxLines: 1,
                                textOverflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            if (ratings != null)
                              Container(
                                width: ratingWidth,
                                height: ratingHeight,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: AppColor.rating),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      AppTextWidget(
                                        text: ratings,
                                        fontSize: addressFontSize - 3,
                                        color: AppColor.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: AppColor.white,
                                        size: addressFontSize - 3,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: ratingWidth,
                                height: ratingHeight,
                              )
                          ],
                        ),
                      ),
                      if ((priceRange != null && priceRange.isNotEmpty) ||
                          (address != null && address.isNotEmpty))
                        Column(
                          children: [
                            SizedBox(height: cardPadding * 0.7),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.sizeOf(context).width *
                                              0.5,
                                    ),
                                    child: AppTextWidget(
                                      text: address,
                                      fontSize: addressFontSize,
                                      textOverflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  AppTextWidget(
                                    text: '$priceRange',
                                    fontSize: addressFontSize,
                                  )
                                ],
                              ),
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
