# Gomezardo — versão inicial Android

Projeto preparado para continuar diretamente no telemóvel e compilar o APK na nuvem com GitHub Actions.

## O que já está incluído
- Mantém a interface original do Gomezardo, com Assistente, Contactos, Notas e Definições.
- Mantém os módulos já existentes de conversa, voz, temporizadores, contactos, notas, configurações e integrações com serviços de IA.
- Adiciona o avatar holográfico ilustrativo de corpo inteiro ao ecrã de conversa por voz.
- Mantém o manifesto e cache PWA.
- Inclui o plugin Android de chamada direta e reconhecimento nativo de voz como base.
- Inclui workflow GitHub Actions para gerar APK de depuração.

## Limites importantes
O avatar atual é uma imagem 2D ilustrativa com animação visual de flutuação, não um modelo 3D animado. A sincronização labial real, modelo 3D, câmara e ações Android avançadas precisam de módulos próprios e testes. As funções já presentes no HTML são preservadas, mas precisam de testes num dispositivo Android. O plugin de chamadas abre o marcador ou pode efetuar chamada direta se a permissão estiver declarada e concedida.

A chave Gemini inserida na aplicação fica no armazenamento local do dispositivo e pode ser extraída por alguém com acesso ao dispositivo. Para distribuição pública, deve ser movida para um backend privado. Não coloques chaves pessoais no GitHub.

## Compilar APK pelo telemóvel
1. Extrai a pasta do ZIP.
2. Cria um repositório no GitHub e envia todos os ficheiros desta pasta (não envies ficheiros `.keystore` nem chaves API).
3. No GitHub, abre **Actions** e executa **Build Gomezardo APK** (ou faz push para `main`).
4. Quando terminar, abre a execução e descarrega o artefacto `Gomezardo-debug-apk`.
5. Extrai `app-debug.apk` e instala no Android. O Android pode pedir autorização para instalar aplicações desta origem.

## Desenvolvimento local
Requer Node.js 20+, Java 21 e Android SDK:

```bash
npm install
npm run build
npx cap add android
npx cap sync android
```

Depois copia `android-plugin/DirectCallPlugin.java` para `android/app/src/main/java/com/gomezardo/app/`, regista o plugin em `MainActivity` e adiciona as permissões necessárias ao Manifest.

## Segurança
O ficheiro de assinatura `.keystore` antigo não foi incluído. Mantém-no privado e guarda cópia segura. O APK do workflow é de depuração, não é uma versão final assinada para publicação.
