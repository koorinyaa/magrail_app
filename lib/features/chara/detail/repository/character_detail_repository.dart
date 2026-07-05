import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_basic_info.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_board_member.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_ico_participant.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_ico_user_info.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_kill_vote.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_sacrifice_result.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_search_item.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_temple_item.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_data.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_user_character.dart';

part 'character_detail_repository/character_detail_repository_basic.dart';
part 'character_detail_repository/character_detail_repository_trade_header.dart';
part 'character_detail_repository/character_detail_repository_trade.dart';
part 'character_detail_repository/character_detail_repository_sacrifice.dart';
part 'character_detail_repository/character_detail_repository_temples.dart';
part 'character_detail_repository/character_detail_repository_board.dart';
part 'character_detail_repository/character_detail_repository_avatar.dart';
part 'character_detail_repository/character_detail_repository_ico.dart';

/// 角色详情仓库
class CharacterDetailRepository {
  /// 创建角色详情仓库
  ///
  /// [apiClient] Tinygrail API 客户端
  const CharacterDetailRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;
}
