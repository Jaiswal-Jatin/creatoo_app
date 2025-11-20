import 'package:creatoo/widgets/app_text_widget.dart';

import '../../../core.dart';
import '../model/BusinessTypeResponseModel.dart';
import '../view_model/category_view_model.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  late CategoryViewModel viewModel;

  @override
  void initState() {
    viewModel = Provider.of<CategoryViewModel>(context, listen: false);
    viewModel.init();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // viewModel = Provider.of<CategoryViewModel>(context);
    // switch (viewModel.categoryResponse.status) {
    //   case Status.loading:
    //     return AppLoadingWidget();
    //   case Status.error:
    //     return AppErrorWidget(message: viewModel.categoryResponse.message.toString());
    //   case Status.completed:
    //     return _buildBody();
    //   default:
    //     return AppNoDataWidget();
    // }

    return _buildStaticBody();
  }

  Widget _buildBody() {
    return AppScaffold(
      appBar: AppBarWidget(
        disableLeadingButton: true,
        title: 'Category',
      ),
      body: viewModel.businessTypeList.isEmpty
          ? Center(
              child: AppTextWidget(text: "Category List is Empty"),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: viewModel.businessTypeList.length,
                  itemBuilder: (context, index) {
                    BusinessType businessType = viewModel.businessTypeList[index];

                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, RoutesName.comingSoonView);
                      },
                      child: Container(
                        height: 220,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              AppImageWidget(
                                imageUrl: businessType.image ?? '',
                                height: 220,
                                width: double.maxFinite,
                                borderRadius: 16,
                                fit: BoxFit.cover,
                              ),
                              // Bottom Opacity Overlay
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  width: double.maxFinite,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black,
                                        Colors.black.withOpacity(0.9),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Restaurant Name (Above Opacity)
                              Positioned(
                                bottom: 10,
                                left: 10,
                                right: 10,
                                child: AppTextWidget(
                                  text: businessType.title ?? '',
                                  textAlign: TextAlign.center,
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  // shadows: [
                                  //   Shadow(
                                  //     color: Colors.black.withOpacity(0.5),
                                  //     blurRadius: 4,
                                  //   ),
                                  // ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
    );
  }

  Widget _buildStaticBody() {
    List<Map<String, String>> categories = [
      {'name': 'Jewellery', 'image': 'assets/images/jewelary.png'},
      {'name': 'Clothing', 'image': 'assets/images/clothes.png'},
      {'name': 'Gifts', 'image': 'assets/images/gifts.png'},
      {'name': 'Printables', 'image': 'assets/images/printables.png'},
      {'name': 'Candles', 'image': 'assets/images/candles.jpg'},
      {'name': 'Stationary', 'image': 'assets/images/stationary.png'},
      {'name': 'Phonecases', 'image': 'assets/images/phonecases.jpg'},
      {'name': 'Books', 'image': 'assets/images/books.png'},
      {'name': 'Homedecor', 'image': 'assets/images/homedecor.jpg'},
    ];

    return AppScaffold(
      appBar: AppBarWidget(
        title: 'Categories',
        disableLeadingButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          physics: BouncingScrollPhysics(), // Enable scrolling
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8, // Taller aspect ratio
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            var category = categories[index];

            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, RoutesName.comingSoonView);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Background Image
                      Positioned.fill(
                        child: Image.asset(
                          category['image']!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Bottom Shadow Overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(1),
                                Colors.black.withOpacity(1),
                                Colors.black.withOpacity(0.8),
                                Colors.black.withOpacity(0.7),
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Category Name
                      Positioned(
                        bottom: 15,
                        left: 10,
                        right: 10,
                        child: Container(
                          alignment: Alignment.center,
                          child: AppTextWidget(
                            text: category['name']!,
                            textAlign: TextAlign.center,
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
  }
}
