import 'member_model.dart';
import 'member_register_model.dart';
import 'open_orders_model.dart';

class MemberDetailResponse {
  final OpenOrdersModel openOrders;
  final List<MemberRegisterModel> memberRegisters;
  final MemberModel member;

  MemberDetailResponse({
    required this.openOrders,
    required this.memberRegisters,
    required this.member,
  });

  factory MemberDetailResponse.fromJson(Map<String, dynamic> json) {
    final output = json['output'];

    return MemberDetailResponse(
      openOrders: OpenOrdersModel.fromJson(output['open_orders']),
      memberRegisters: List<MemberRegisterModel>.from(
        output['member_registers'].map((x) => MemberRegisterModel.fromJson(x)),
      ),
      member: MemberModel.fromJson(output['member']),
    );
  }
}
