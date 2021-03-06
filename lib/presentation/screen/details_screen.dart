import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reciply/constants/app_colors.dart';
import 'package:reciply/constants/localization_constains.dart';
import 'package:reciply/domain/recipe_model.dart';
import 'package:reciply/presentation/widgets/loading.dart';
import 'package:reciply/presentation/widgets/size.dart';
import 'package:reciply/presentation/widgets/text_display.dart';
import 'package:reciply/utils/database_hepler.dart';

class DetailsScreen extends StatefulWidget {
  final RecipeModel recipe;
  final DatabaseHelper db;

  const DetailsScreen(this.recipe, this.db, {Key? key}) : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            buildSliverAppBar(),
            buildSliverList(),
          ],
        ),
      ),
      floatingActionButton: buildFloatingActionButton(),
    );
  }

  FloatingActionButton buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: AppColor.white,
      onPressed: () {},
      child: FutureBuilder<bool>(
          future: widget.db.recipeExists(widget.recipe),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);
            var data = snapshot.data;
            if (!snapshot.hasData || data == null) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: LoadingWidget(),
              );
            } else {
              print("Is Favorite: ${snapshot.data}");
              return IconButton(
                onPressed: () {
                  if (snapshot.data!) {
                    widget.db.removeFavRecipe(widget.recipe);
                  } else {
                    widget.db.addFavRecipe(widget.recipe);
                  }
                  setState(() {});
                },
                icon: Icon(
                    data ? Icons.favorite : Icons.favorite_border_outlined,
                    color: AppColor.brown),
              );
            }
          }),
    );
  }

  SliverList buildSliverList() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            color: AppColor.lightGrey,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40.0),
                  topLeft: Radius.circular(40.0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextDisplay(
                    text: widget.recipe.name,
                    fontWeight: FontWeight.w600,
                    color: AppColor.brown,
                    textAlign: TextAlign.start,
                    fontSize: 18,
                    fontFamily: "BalsamiqSans",
                  ),
                  HeightBox(4),
                  AppTextDisplay(
                    text: "${widget.recipe.headline}, ${widget.recipe.country}",
                    textAlign: TextAlign.start,
                    fontSize: 12,
                  ),
                  if (widget.recipe.ingredients != null) buildIngredients(),
                  HeightBox(12),
                  AppTextDisplay(
                    translation: kDescription,
                    fontWeight: FontWeight.w600,
                    color: AppColor.darkGrey,
                    textAlign: TextAlign.start,
                    fontFamily: "BalsamiqSans",
                  ),
                  HeightBox(4),
                  AppTextDisplay(
                    text: widget.recipe.description,
                    textAlign: TextAlign.start,
                    maxLines: 15,
                    fontSize: 14,
                  ),
                  HeightBox(50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIngredients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeightBox(12),
        AppTextDisplay(
          translation: kIngredients,
          fontWeight: FontWeight.w600,
          color: AppColor.darkGrey,
          textAlign: TextAlign.start,
          fontFamily: "BalsamiqSans",
        ),
        HeightBox(4),
        for (int i = 0; i < widget.recipe.ingredients!.length; i++)
          AppTextDisplay(
            text: widget.recipe.ingredients![i],
            textAlign: TextAlign.start,
            maxLines: 15,
            fontSize: 14,
          ),
      ],
    );
  }

  Widget buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      stretch: true,
      backgroundColor: AppColor.lightGrey,
      iconTheme: const IconThemeData(color: Colors.black),
      flexibleSpace: FlexibleSpaceBar(
        background: Row(
          children: [
            WidthBox(8),
            buildRecipeDetails(),
            const Spacer(),
            Hero(
              tag: widget.recipe.id!,
              child: buildCachedNetworkImage(widget.recipe),
            ),
            WidthBox(8),
          ],
        ),
      ),
    );
  }

  Widget buildRecipeDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.recipe.fats != null && widget.recipe.fats!.isNotEmpty)
          buildDetailsItem("Fats", widget.recipe.fats!),
        if (widget.recipe.carbos != null && widget.recipe.carbos!.isNotEmpty)
          buildDetailsItem("Carbos", widget.recipe.carbos!),
        if (widget.recipe.calories != null &&
            widget.recipe.calories!.isNotEmpty)
          buildDetailsItem("Calories", widget.recipe.calories!),
        if (widget.recipe.proteins != null &&
            widget.recipe.proteins!.isNotEmpty)
          buildDetailsItem("Fibers", widget.recipe.proteins!),
      ],
    );
  }

  Widget buildDetailsItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.defaultGrey),
        // color: AppColor.lightGrey,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: Row(
        children: [
          AppTextDisplay(
            text: title,
            fontWeight: FontWeight.w500,
            color: AppColor.brown,
            fontFamily: "BalsamiqSans",
          ),
          WidthBox(4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: AppTextDisplay(
              text: value,
              fontSize: 14.sp,
              color: AppColor.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCachedNetworkImage(RecipeModel recipe) {
    if (recipe.image == null) {
      return const Icon(Icons.error);
    } else {
      return CircleAvatar(
        radius: 100,
        child: ClipOval(
          child: CachedNetworkImage(
            height: double.infinity,
            placeholder: (context, url) => LoadingWidget(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            imageUrl: recipe.image!,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }
}
