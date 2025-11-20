class OnboardingModel {
  String? title;
  String? description;
  String? image;

  OnboardingModel({this.title, this.description, this.image});

  static var data = [
    OnboardingModel(
      title: 'Discover, Earn & Enjoy with Creatoo!',
      description:
          "Find your favorite brands, earn loyalty points on every bill, and redeem them for exciting rewards. Start your rewarding journey today!",
      image: "assets/icons/onboard-1.svg",
    ),
  ];
}
