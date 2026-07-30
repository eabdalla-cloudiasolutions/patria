import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/core/routing/routes.dart';
import 'package:patria/core/utils/emoji_input_formatter.dart';
import 'package:patria/core/widgets/empty_state_widget.dart';
import 'package:patria/features/home/data/models/product_model.dart';
import 'package:patria/features/home/data/repos/products_repo.dart';
import 'package:patria/features/home/presentation/manager/search_bloc.dart';
import 'package:patria/features/home/presentation/manager/search_event.dart';
import 'package:patria/features/home/presentation/manager/search_state.dart';
import 'package:patria/features/home/presentation/views/widgets/cuisines_section.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

// ─────────────────────────────────────────────
// Mixin: reusable typewriter animation logic
// ─────────────────────────────────────────────
mixin TypewriterMixin<T extends StatefulWidget> on State<T> {
  Timer? _typewriterTimer;
  int _wordIndex = 0;
  int _charIndex = 0;
  bool _isDeleting = false;
  String animatedWord = '';

  List<String> get hintWords;
  bool get isPaused => false;

  void startTypewriter() {
    _typewriterTimer?.cancel();
    _typewriterTimer = Timer.periodic(
      const Duration(milliseconds: 180),
      (_) => _tick(),
    );
  }

  void _tick() {
    if (hintWords.isEmpty || isPaused) return;

    final currentWord = hintWords[_wordIndex];

    if (!_isDeleting) {
      if (_charIndex < currentWord.length) {
        animatedWord = currentWord.substring(0, _charIndex + 1);
        _charIndex++;
      } else {
        _isDeleting = true;
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() {});
        });
        return;
      }
    } else {
      if (_charIndex > 0) {
        animatedWord = currentWord.substring(0, _charIndex - 1);
        _charIndex--;
      } else {
        _isDeleting = false;
        _wordIndex = (_wordIndex + 1) % hintWords.length;
        _charIndex = 0;
      }
    }
    setState(() {});
  }

  void disposeTypewriter() {
    _typewriterTimer?.cancel();
  }
}

// ─────────────────────────────────────────────
// HomeSearchBar — tappable bar on home screen
// ─────────────────────────────────────────────
class HomeSearchBar extends StatefulWidget {
  final PersistentTabController? controller;

  const HomeSearchBar({super.key, this.controller});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar>
    with TypewriterMixin<HomeSearchBar> {
  @override
  List<String> get hintWords => [
    'search_hint_bakery'.tr(),
    'search_hint_croissant'.tr(),
    'search_hint_sandwich'.tr(),
    'search_hint_coffee'.tr(),
  ];

  @override
  void initState() {
    super.initState();
    startTypewriter();
  }

  @override
  void dispose() {
    disposeTypewriter();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: SearchScreen(controller: widget.controller),
        withNavBar: true,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.w, color: const Color(0xFFCACBD4)),
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Row(
          children: [
            Image.asset('assets/images/search.png'),
            SizedBox(width: 10.w),
            Text(
              animatedWord.isEmpty
                  ? 'search_for'.tr()
                  : '${'search_for'.tr()} $animatedWord',
              style: TextStyle(
                color: const Color(0xFF8B8B8B),
                fontSize: 16.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                letterSpacing: 0.32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SearchScreen
// ─────────────────────────────────────────────
class SearchScreen extends StatefulWidget {
  final PersistentTabController? controller;

  const SearchScreen({super.key, this.controller});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductsRepo _productsRepo = ProductsRepo();
  final TextEditingController _searchController = TextEditingController();
  late final SearchBloc _searchBloc;
  String _query = '';
  Timer? _debounceTimer;

  static const _accentColor = Color(0xFF3C4119);

  @override
  void initState() {
    super.initState();
    _searchBloc = SearchBloc();
    _searchBloc.add(LoadSearchHistory());
  }

  String _lastLoggedQuery = '';

  void _onChanged(String value) {
    setState(() => _query = value);

    if (value.trim().isNotEmpty) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(seconds: 1), () {
        final trimmed = value.trim();
        if (trimmed != _lastLoggedQuery) {
          _lastLoggedQuery = trimmed;
          _searchBloc.add(LogSearchQuery(trimmed));
        }
      });
    }
  }

  void _onSubmit(String query) {
    if (query.trim().isEmpty) return;
    _debounceTimer?.cancel();
    final trimmed = query.trim();
    if (trimmed != _lastLoggedQuery) {
      _lastLoggedQuery = trimmed;
      _searchBloc.add(LogSearchQuery(trimmed));
    }
  }

  void _applyQuery(String query) {
    _searchController.text = query;
    setState(() => _query = query);
    _debounceTimer?.cancel();
    final trimmed = query.trim();
    if (trimmed != _lastLoggedQuery) {
      _lastLoggedQuery = trimmed;
      _searchBloc.add(LogSearchQuery(trimmed));
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F7F7),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'search'.tr(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: _SearchField(
                controller: _searchController,
                onChanged: _onChanged,
                onSubmitted: _onSubmit,
              ),
            ),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: _query.trim().isEmpty
                    ? _buildIntroContent()
                    : _buildSearchResults(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is SearchHistoryLoading) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: _accentColor,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              if (state is SearchTrendingLoaded) {
                final historyCuisines = state.history
                    .map((item) => CuisineItem(name: item))
                    .toList();

                final trendingCuisines = state.trending
                    .map((item) => CuisineItem(name: item))
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ History
                    if (historyCuisines.isNotEmpty) ...[
                      CuisinesSection(
                        title: 'history_title'.tr(),
                        cuisines: historyCuisines,
                        onCuisineTap: _applyQuery,
                        // ✅ Trash icon
                        titleTrailing: GestureDetector(
                          onTap: () => context.read<SearchBloc>().add(
                            ClearSearchHistory(),
                          ),
                          child: Image.asset(
                            'assets/images/trash-option.png',
                            height: 24.h,
                            width: 24.w,
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                    ],

                    // ✅ Trending from API
                    if (trendingCuisines.isNotEmpty) ...[
                      CuisinesSection(
                        title: 'top_trending_title'.tr(),
                        cuisines: trendingCuisines,
                        onCuisineTap: _applyQuery,
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<ProductModel>>(
      future: _productsRepo.getProducts(search: _query.trim()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _accentColor),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: const Color(0xFF8B8B8B), fontSize: 14.sp),
            ),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return EmptyStateWidget(
            imagePath: 'assets/images/Empty Search.png',
            title: 'no_results_for_query'.tr(namedArgs: {'query': _query}),
            subtitle: 'empty_search_subtitle'.tr(),
            buttonText: 'browse_menu'.tr(),
            onButtonPressed: () => widget.controller != null
                ? widget.controller!.jumpToTab(0)
                : Navigator.pop(context),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: Color(0xFFE5E5E5)),
          itemBuilder: (_, index) => _ProductTile(product: products[index]),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Product Tile
// ─────────────────────────────────────────────
class _ProductTile extends StatelessWidget {
  final ProductModel product;

  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.network(
          product.imageUrl,
          width: 56.w,
          height: 56.h,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      ),
      title: Text(
        product.name,
        style: const TextStyle(
          color: Color(0xFF333333),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${product.price} EGP',
        style: const TextStyle(
          color: Color(0xFF3C4119),
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Color(0xFF8B8B8B),
      ),
      onTap: () => Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamed(Routes.itemPreview, arguments: product),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E8D3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.fastfood_outlined, color: Color(0xFF3C4119)),
    );
  }
}

// ─────────────────────────────────────────────
// Animated Search Field
// ─────────────────────────────────────────────
class _SearchField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function(String) onSubmitted;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField>
    with TypewriterMixin<_SearchField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  List<String> get hintWords => [
    'search_hint_bakery'.tr(),
    'search_hint_croissant'.tr(),
    'search_hint_sandwich'.tr(),
    'search_hint_coffee'.tr(),
  ];

  @override
  bool get isPaused => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(
      () => setState(() => _isFocused = _focusNode.hasFocus),
    );
    startTypewriter();
  }

  @override
  void dispose() {
    disposeTypewriter();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFF3C4119);
    final borderColor = _isFocused ? accentColor : const Color(0xFFCACBD4);
    final hintColor = _isFocused
        ? accentColor.withOpacity(0.7)
        : const Color(0xFF8B8B8B);
    final iconColor = _isFocused ? accentColor : const Color(0xFF8B8B8B);

    final hint = _isFocused || animatedWord.isEmpty
        ? 'search_for'.tr()
        : '${'search_for'.tr()} $animatedWord';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(width: 1.w, color: borderColor),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
        inputFormatters: [EmojiInputFormatter()],
        style: TextStyle(
          color: _isFocused ? Colors.black : const Color(0xFF8B8B8B),
          fontSize: 16.sp,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w400,
          letterSpacing: 0.32,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: hintColor,
            fontSize: 16.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            letterSpacing: 0.32,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(14),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              child: Image.asset(
                'assets/images/search.png',
                width: 20.w,
                height: 20.h,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
