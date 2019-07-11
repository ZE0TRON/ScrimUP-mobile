import 'dart:convert';

import 'package:ScrimUp/models/Event.dart';
import 'package:ScrimUp/models/Link.dart';
import 'package:ScrimUp/models/Strategy.dart';
import 'package:ScrimUp/models/Task.dart';
import 'package:ScrimUp/models/Team.dart';
import 'package:ScrimUp/utils/session.dart';
import 'Parser.dart';
import 'Queries.dart';

class Request {
  Session _session;
  final _query = Query();
  final _parser = Parser();
  Request(this._session);
  // URLs Of the requests
  String getInviteLinkUrl = "/team/getInviteLink";
  String createEventUrl = "/team/createEvent";
  String createStrategyUrl = "/strategy/add";
  String getStrategyUrl = "/strategy/get";
  String deleteStrategyUrl = "/strategy/delete";
  String createTaskUrl = "/task/add";
  String getTaskUrl = "/task/get";
  String deleteTaskUrl = "/task/delete";
  String progressTaskUrl = "/task/progress";
  String strategyStatusChangeUrl = "/strategy/update";
  String getTokenUrl = "/team/getToken";
  String getGamesUrl = "/account/getGames";

  Future<Link> inviteLinkRequest(Team team) => Future(() async {
        var jsonPayload = _query.getInviteLinkQuery(team.game, team.team);
        var response = await _session.apiRequest(getInviteLinkUrl, jsonPayload);
        Link link = _parser.getInviteLinkParse(response);
        return link;
      });
  Future<String> createEventRequest(Event event, Team team) => Future(() async {
        print("createEventRequest start");
        var jsonPayload = _query.createEventQuery(event, team);
        print("JsonPayload created");
        var response = await _session.apiRequest(createEventUrl, jsonPayload);
        print("Post sent");
        var message = _parser.createEventParse(response);
        print("Response parsed");
        return message;
      });
  Future<String> createStrategyRequest(Strategy strategy, String game) =>
      Future(() async {
        var jsonPayload = _query.createStrategyQuery(game, strategy);
        var response =
            await _session.apiRequest(createStrategyUrl, jsonPayload);
        var message = _parser.createStrategyParse(response);
        return message;
      });
  Future<List<Strategy>> getStrategiesRequest(String game) => Future(() async {
        var jsonPayload = _query.getStrategiesQuery(game);
        var response = await _session.apiRequest(getStrategyUrl, jsonPayload);
        List<Strategy> strategies = _parser.getStrategiesParse(response);
        return strategies;
      });
  Future<String> deleteStrategyRequest(Strategy strategy, String game) =>
      Future(() async {
        var jsonPayload = _query.deleteStrategyQuery(game, strategy);
        var response =
            await _session.apiRequest(deleteStrategyUrl, jsonPayload);
        var message = _parser.deleteStrategyParse(response);
        return message;
      });

  Future<String> createTaskRequest(Task task, String game) => Future(() async {
        var jsonPayload = _query.createTaskQuery(game, task);
        var response = await _session.apiRequest(createTaskUrl, jsonPayload);
        var message = _parser.createTaskParse(response);
        return message;
      });
  Future<List<Task>> getTasksRequest(String game) => Future(() async {
        var jsonPayload = _query.getTasksQuery(game);
        var response = await _session.apiRequest(getTaskUrl, jsonPayload);
        List<Task> tasks = _parser.getTasksParse(response);
        return tasks;
      });
  Future<String> progressTaskRequest(Task task, String game) =>
      Future(() async {
        var jsonPayload = _query.progressTaskQuery(game, task);
        var response = await _session.apiRequest(progressTaskUrl, jsonPayload);
        var message = _parser.progressTaskParse(response);
        return message;
      });
  Future<String> deleteTaskRequest(Task task, String game) => Future(() async {
        var jsonPayload = _query.deleteTaskQuery(game, task);
        var response = await _session.apiRequest(deleteTaskUrl, jsonPayload);
        var message = _parser.deleteTaskParse(response);
        return message;
      });
  Future<String> strategyStatusChangeRequest(
          Strategy strategy, String game, bool isWin) =>
      Future(() async {
        var jsonPayload =
            _query.strategyStatusChangeQuery(game, strategy, isWin);
        var response =
            await _session.apiRequest(strategyStatusChangeUrl, jsonPayload);
        var message = _parser.strategyStatusChangeParse(response);
        return message;
      });
  Future<String> getTokenRequest(Team team) => Future(() async {
        var jsonPayload = _query.getTokenQuery(team);
        var response = await _session.apiRequest(getTokenUrl, jsonPayload);
        var token = _parser.getTokenParse(response);
        return token;
      });

  Future<List<List<String>>> getGamesRequest() => Future(() async {
        var response = await _session.apiRequest(getGamesUrl, {});
        var data = _parser.getGamesParse(response);
        return data;
      });
}
