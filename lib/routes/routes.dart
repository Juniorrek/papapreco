import 'package:premiumprice/main.dart';
import 'package:premiumprice/view/auth/cadastro_page.dart';
import 'package:premiumprice/view/auth/esqueci_senha_codigo_page.dart';
import 'package:premiumprice/view/auth/esqueci_senha_page.dart';
import 'package:premiumprice/view/auth/esqueci_senha_redefinicao_page.dart';
import 'package:premiumprice/view/auth/login_page.dart';
import 'package:premiumprice/view/definir_localizacao_page.dart';
import 'package:premiumprice/view/produto/cadastrar_produto_page.dart';
import 'package:premiumprice/view/produto/confirmar_digitalizacao_page.dart';
import 'package:premiumprice/view/produto/detalhe_produto_page.dart';
import 'package:premiumprice/view/produto/digitalizar_nota_page.dart';
import 'package:premiumprice/view/produto/filtrar_produtos_page.dart';
import 'package:premiumprice/view/produto/listar_produtos_mapa_page.dart';
import 'package:premiumprice/view/produto/listar_produtos_page.dart';
import 'package:premiumprice/view/produto/sugerir_edicao_page.dart';

class Routes {
  static const String home = MyHomePage.routeName;

  static const String listarProdutos = ListarProdutosPage.routeName;

  static const String detalheProduto = DetalheProdutoPage.routeName;
  static const String listarProdutosMapa = ListarProdutosMapaPage.routeName;
  static const String filtrarProdutos = FiltrarProdutosPage.routeName;

  static const String sugerirEdicao = SugerirEdicaoPage.routeName;
  static const String cadastrarProduto = CadastrarProdutoPage.routeName;

  static const String definirLocalizacao = DefinirLocalizacaoPage.routeName;

  static const String digitalizarNota = DigitalizarNotaPage.routeName;
  static const String confirmarDigitalizacao = ConfirmarDigitalizacaoPage.routeName;

  static const String login = LoginPage.routeName;
  static const String cadastro = CadastroPage.routeName;

  static const String esqueciSenha = EsqueciSenhaPage.routeName;
  static const String esqueciSenhaCodigo = EsqueciSenhaCodigoPage.routeName;
  static const String esqueciSenhaRedefinicao = EsqueciSenhaRedefinicaoPage.routeName;
}