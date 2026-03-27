import 'package:flutter/material.dart';
import '../../model/block_config.dart';

/// Base class for block dispatchers.
/// Each page type (PDP, PLP, Cart) extends this with its own block → widget mapping.
abstract class BlockDispatcher {
  /// Returns the widget for a given block config.
  /// Subclasses implement the switch on block.component.
  Widget buildBlock(BlockConfig block);

  /// Renders all enabled blocks in order.
  List<Widget> buildBlocks(PageConfig pageConfig) {
    return pageConfig.enabledBlocks.map((block) => buildBlock(block)).toList();
  }

  /// Renders all enabled blocks as a Column.
  Widget buildBlockColumn(PageConfig pageConfig) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: buildBlocks(pageConfig),
    );
  }

  /// Renders all enabled blocks as a scrollable list.
  Widget buildBlockList(PageConfig pageConfig, {ScrollController? controller}) {
    final blocks = pageConfig.enabledBlocks;
    return ListView.builder(
      controller: controller,
      itemCount: blocks.length,
      itemBuilder: (context, index) => buildBlock(blocks[index]),
    );
  }
}
