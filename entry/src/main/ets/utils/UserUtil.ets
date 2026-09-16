import { User } from '../viewmodel/User';

export function loginUserAction(loginAction: (user: User) => void = () => {},
  noLoginAction: () => void = () => {}): void {
  const isLogin = AppStorage.get('isLogin') as boolean;
  if (!isLogin) {
    noLoginAction();
    return;
  }

  const user = AppStorage.get('user') as User;
  if (user === undefined || user === null || user.id <= 0) {
    noLoginAction();
    return;
  }
  loginAction(user);
}
