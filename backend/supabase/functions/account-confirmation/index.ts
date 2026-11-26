// Public informational return route only. No database, credentials or auth SDK.
// Supabase's free function gateway serves HTML as plain text, so keep it honest.
const RETURN_URL = "https://vtvvevevkhqwyemrpawy.supabase.co/functions/v1/account-confirmation";
const messages = {
  en: "THE KNIGHT OF LAST LIGHT\n\nRETURN TO THE GAME\n\nOpen Account → Sign in in the game. Use the email and password you registered with.\n\nThis page does not report whether verification succeeded. If the game says your email is not confirmed, choose Resend confirmation email and use the newest message. An old or already used link may have expired.\n\nYou can close this tab. Your local journeys remain safe.",
  bg: "РИЦАРЯТ НА ПОСЛЕДНАТА СВЕТЛИНА\n\nВЪРНЕТЕ СЕ В ИГРАТА\n\nОтворете Акаунт → Вход в играта. Използвайте имейла и паролата, с които се регистрирахте.\n\nТази страница не показва дали потвърждението е успешно. Ако играта съобщава, че имейлът не е потвърден, изберете Изпрати нов имейл за потвърждение и отворете най-новото писмо. Стар или вече използван линк може да е изтекъл.\n\nМожете да затворите този раздел. Локалните ви пътешествия са запазени.",
  ru: "РЫЦАРЬ ПОСЛЕДНЕГО СВЕТА\n\nВЕРНИТЕСЬ В ИГРУ\n\nОткройте Аккаунт → Войти в игре. Используйте адрес и пароль, указанные при регистрации.\n\nЭта страница не подтверждает результат проверки. Если игра сообщает, что адрес не подтверждён, запросите новое письмо подтверждения и откройте самое новое сообщение. Старая или уже использованная ссылка могла истечь.\n\nЭту вкладку можно закрыть. Локальные путешествия сохранены.",
  fr: "LE CHEVALIER DE LA DERNIÈRE LUMIÈRE\n\nRETOURNEZ DANS LE JEU\n\nOuvrez Compte → Connexion dans le jeu. Utilisez l’adresse e-mail et le mot de passe de votre inscription.\n\nCette page n’indique pas si la vérification a réussi. Si le jeu indique que l’adresse n’est pas confirmée, demandez un nouvel e-mail de confirmation et ouvrez le message le plus récent. Un lien ancien ou déjà utilisé peut avoir expiré.\n\nVous pouvez fermer cet onglet. Vos parties locales restent sauvegardées.",
  ar: "فارس النور الأخير\n\nعُد إلى اللعبة\n\nافتح الحساب ← تسجيل الدخول في اللعبة. استخدم البريد الإلكتروني وكلمة المرور اللذين سجلت بهما.\n\nلا توضح هذه الصفحة ما إذا نجح التحقق. إذا أخبرتك اللعبة أن البريد غير مؤكد، فاطلب رسالة تأكيد جديدة وافتح أحدث رسالة. قد يكون الرابط القديم أو المستخدم منتهي الصلاحية.\n\nيمكنك إغلاق علامة التبويب. رحلاتك المحلية محفوظة."
};
export function handleRequest(request) {
  const headers = {
    "Content-Type": "text/plain; charset=utf-8",
    "Cache-Control": "no-store",
    "Referrer-Policy": "no-referrer",
    "X-Content-Type-Options": "nosniff",
    "Content-Security-Policy": "default-src 'none'; frame-ancestors 'none'"
  };
  if (!["GET", "HEAD"].includes(request.method)) {
    return new Response("Method not allowed", { status: 405, headers: { ...headers, Allow: "GET, HEAD" } });
  }
  // A fixed explicit fragment replaces the incoming auth-session/error fragment.
  // No credential is read, echoed, exchanged or forwarded to any other origin.
  if (new URL(request.url).searchParams.get("view") !== "return") {
    return new Response(null, { status: 303, headers: { ...headers, Location: RETURN_URL + "?view=return#last-light" } });
  }
  const accepted = (request.headers.get("accept-language") || "en").split(",");
  const language = accepted.map(value => value.trim().split(";")[0].split("-")[0].toLowerCase()).find(value => messages[value]) || "en";
  return new Response(request.method === "HEAD" ? null : messages[language], { status: 200, headers });
}
if (typeof Deno !== "undefined") Deno.serve(handleRequest);
