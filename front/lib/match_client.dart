import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:grpc/grpc.dart';
import './generated/match.pbgrpc.dart';

class MatchClient {
  late ClientChannel channel;
  late MatchServiceClient stub;

  MatchClient() {
    channel = ClientChannel(
      '${dotenv.env['API_IP']}',
      port: 50051,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    stub = MatchServiceClient(channel);
  }

  Stream<MatchResponse> subscribeMatchUpdates(int matchId) {
    var request = MatchRequest(matchId: matchId);
    return stub.subscribeMatchUpdates(request);
  }

  void shutdown() async {
    await channel.shutdown();
  }

}