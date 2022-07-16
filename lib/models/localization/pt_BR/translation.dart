import '../translation.dart';

class TranslationPtBr implements Translation {
  @override
  final String slogan = 'Acesse links entre seus dispositivos';
  @override
  final String passwordRule = 'A senha deve ter 6 ou mais caracteres';
  @override
  final String voidLink = 'Nenhum link encontrado!';
  @override
  final String addLink = 'Adicione um link para começar!';
  @override
  final String voidHistory = 'Nenhuma atividade recente para mostrar aqui!';
  @override
  final String switchTheme = 'Trocar tema';
  @override
  final String cameraPermission = 'Dê permissão para usar a câmera';

  @override
  final Map<String, String> button = {
    'forgot_password': 'Esqueceu sua senha?',
    'sign_in': 'Entrar',
    'sign_up': 'Criar',
    'sign_in_with_google': 'Entrar com Google',
    'accept_policy_privacy1': 'Li e aceito a ',
    'accept_policy_privacy2': 'Política de Privacidade',
    'accept_terms_of_use1': 'Li e aceito os ',
    'accept_terms_of_use2': 'Termos de Uso',
    'dont_have_account': 'Não tem uma conta? Faça agora!',
    'have_account': 'Já tem uma conta? Então, entre!',
    'save_to_gallery': 'SALVAR NA GALERIA',
    'open_link': 'Abrir link',
    'save_link': 'Salvar link',
    'copy_link': 'Copiar link',
    'add_link': 'Adicionar link',
  };

  @override
  final Map<String, dynamic> titles = {
    'filters': 'Filtros',
    'history': 'Histórico',
  };

  @override
  final Map<String, dynamic> placeholder = {
    'email': 'E-mail',
    'password': 'Senha',
    'search': 'Título, URL, data...',
    'add_link_title': 'Título',
    'add_link_url': 'URL',
    'add_filter': 'Filtro',
  };

  @override
  final Map<String, dynamic> snackbar = {
    'launch_url': 'Não foi possível abrir esta URL!',
    'copy_url': 'URL copiada para a área de transferência!',
    'qr_saved': 'QR code salvo na galeria!',
    'storage_permission':
        'Não foi possível salvar o QR code. Você deu permissão para o armazenamento?',
  };

  @override
  final Map<String, dynamic> dialog = {
    'accept_privacy_policy':
        'Você deve aceitar a Política de Privacidade e os Termos de Uso para criar uma conta!',
    'title': 'Tem certeza?',
    'filter_content':
        'Todos os seus links dentro desse filtro serão deletados!',
    'history_content':
        'Isso irá apagar toda a linha do tempo do seu histórico!',
    'buttons': {
      'yes': 'Sim',
      'no': 'Não',
    },
  };

  @override
  final Map<String, dynamic> drawer = {
    'history': 'Histórico',
    'web_version': 'Versão web',
    'about': 'Sobre o app',
    'sign_out': 'Sair',
  };
}
