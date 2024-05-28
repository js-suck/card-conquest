import 'dart:ffi';

import 'package:grpc/grpc.dart';
import './../generated/tournament.pbgrpc.dart';

class TournamentClient {
  late ClientChannel channel;
  late TournamentServiceClient stub;

  TournamentClient() {
    channel = ClientChannel(
      '10.0.2.2', // Utilisez localhost si vous êtes sur le même appareil, sinon utilisez l'IP de votre serveur
      port: 50051,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    stub = TournamentServiceClient(channel);
  }

Stream<TournamentResponse> subscribeTournamentUpdate(int tournamentId) {
  var request = TournamentRequest(tournamentId: tournamentId);
  return stub.suscribeTournamentUpdate(request);
}

  void shutdown() async {
    await channel.shutdown();
  }
}
