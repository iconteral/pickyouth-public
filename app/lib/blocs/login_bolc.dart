import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bloc/bloc.dart';
import 'package:app/events/login_events.dart';
import 'package:app/states/login_states.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginFailedEvent) {
      yield LoginFailed(errorMessage: event.errorMessage);
    }
    if (event is LoggedInEvent) {
      yield LoggedIn(event.client);
    }
    if (event is LoginPressedEvent) {
      BaseOptions options = BaseOptions(baseUrl: "http://39.105.70.152:8080");
      Dio client = new Dio(options);
      var dataPath = await getApplicationDocumentsDirectory();
      var cookieJar = PersistCookieJar(dir: dataPath.path);
      client.interceptors.add(CookieManager(cookieJar));
      if (event.username == "" || event.password == "") {
        this.dispatch(LoginFailedEvent(errorMessage: "不能为空"));
      } else {
        var postData = {"username": event.username, "password": event.password};
        FormData formData = FormData.from(postData);
        Response response = await client.post("/login", data: formData);
        if (response.data.toString() == 'wrong.') {
          this.dispatch(LoginFailedEvent(errorMessage: "信息错误"));
        } else {
          this.dispatch(LoggedInEvent(client));
        }
      }
    }
  }
}
