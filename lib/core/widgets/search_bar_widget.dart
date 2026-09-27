// import 'package:patria/core/services/search_service.dart';
// import 'package:flutter/material.dart';

// class SearchBarWidget extends StatefulWidget {
//   final Function(String) onChanged;
//   final VoidCallback onClear;
//   final String textValue;
//   const SearchBarWidget({
//     super.key,
//     required this.onChanged,
//     required this.onClear,
//     this.textValue = '',
//   });

//   @override
//   State<SearchBarWidget> createState() => _SearchBarWidgetState();
// }

// class _SearchBarWidgetState extends State<SearchBarWidget> {
//   final TextEditingController _controller = TextEditingController();
//   bool _hasText = false;
//   @override
//   void didUpdateWidgetState(SearchBarWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // only update if text actually changed from outside
//     if (widget.textValue != oldWidget.textValue &&
//         widget.textValue != _controller.text) {
//       _controller.removeListener(_onChanged);
//       _controller.text = widget.textValue;

//       //move cursor to end after setting text
//       _controller.selection = TextSelection.fromPosition(
//         TextPosition(offset: _controller.text.length),
//       );
//       _controller.addListener(_onChanged);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _controller.addListener(
//       () {
//         setState(
//           () => _hasText = _controller.text.isNotEmpty,
//         );
//       },
//     );
//   }

//   void setTextSilently(String text) {
//     _controller.removeListener(_onChanged);
//     _controller.text = text;
//     _controller.addListener(_onChanged);
//   }

//   void _onChanged() => widget.onChanged(_controller.text);
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
//       ),
//       child: TextField(
//         controller: _controller,
//         onChanged: (_) => widget.onChanged(_controller.text),
//         decoration: InputDecoration(
//             hintText: 'Search destination... ',
//             prefixIcon: const Icon(Icons.search),
//             suffixIcon: _hasText
//                 ? IconButton(
//                     icon: const Icon(Icons.clear),
//                     onPressed: () {
//                       _controller.clear();
//                       widget.onClear();
//                     })
//                 : null,
//             border: InputBorder.none,
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
//       ),
//     );
//   }
// }

// // suggestionsListWidget
// class SuggestionsListWidget extends StatelessWidget {
//   final List<PlaceSuggestion> suggestions;
//   final Function(PlaceSuggestion) onSelected;

//   const SuggestionsListWidget({
//     super.key,
//     required this.suggestions,
//     required this.onSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
//         ),
//         child: ListView.separated(
//             padding: EdgeInsets.zero,
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemBuilder: (context, index) {
//               final s = suggestions[index];
//               return ListTile(
//                 leading:
//                     const Icon(Icons.location_on_outlined, color: Colors.red),
//                 title: Text(
//                   s.name,
//                   style: const TextStyle(fontWeight: FontWeight.w600),
//                 ),
//                 subtitle: Text(
//                   s.fullAddress,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 onTap: () => onSelected(s),
//               );
//             },
//             separatorBuilder: (_, __) => Divider(height: 1),
//             itemCount: suggestions.length));
//   }
// }
