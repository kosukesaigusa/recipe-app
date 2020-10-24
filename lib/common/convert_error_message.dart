String convertErrorMessage(eCode) {
  switch (eCode) {
    case 'user-not-found':
      return 'ユーザーが見つかりません。';
    case 'user-disabled':
      return 'ユーザーが無効です。';
    case 'wrong-password':
      return 'パスワードが正しくありません。';
    case 'too-many-requests':
      return 'しばらく時間を置いて再度お試し下さい。';
    case 'invalid-email':
      return 'メールアドレスを正しい形式で入力して下さい。';
    case 'email-already-in-use':
      return 'そのメールアドレスは既に使用されています。';
    case 'requires-recent-login':
      return '一度ログアウトしてから再度お試し下さい。';
    default:
      return 'エラーが発生しました。';
  }
}
