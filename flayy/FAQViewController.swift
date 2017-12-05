//
//  FAQViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 12/4/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController {

    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var question: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let items = [FAQItem(question: "Qué es Waspy?", answer: "Waspy es un servicio de localización privada para tu familia y amigos, ofrecemos un medio para compartir información precisa acerca de la ubicación y dirección de tus seres queridos. Incorpora funciones como creación de Grupos, Geocercas y un Mapa de alertas que muestra los siniestros reportados por otros usuarios tales como agresiones, acosos, asaltos, moto atracos y robos. Tambien podras notificar a 3 miembros de tus contactos si estas en alguna situacion de peligro a traves de un boton de panico."),
                     FAQItem(question: "¿Para qué usar Waspy?", answer: "Waspy te permite estar al pendiente de tus seres queridos brindándote información en tiempo real de la ubicación precisa de tu familia y amigos organizados en grupos. Con Waspy puedes crear Geocercas y ser notificado cuando un integrante de tus grupos abandona o llega a una Geocerca. Así mismo con el Mapa de alertas puedes explorar cualquier zona para descubrir los delitos que se han cometido últimamente en esa zona y tomar precauciones."),
                     FAQItem(question: "¿En qué dispositivos lo puedo usar?", answer: "Waspy esta desarrollado para funcionar en smartphones únicamente. Tenemos la aplicación para iOS (10 o superior) y Android (4.1 o superior)."),
                     FAQItem(question: "¿Quiénes pueden verme en Waspy?", answer: "El servicio de localización de Waspy es privado por lo que solo las personas que pertenezcan a unos de tus grupos podrán ver tu estado y ubicación en el mapa. Así mismo cada integrante de un grupo tiene la posibilidad de ocultar su ubicación y estado a los demás miembros del grupo."),
                     FAQItem(question: "¿Cómo puedo ocultar mi ubicación en Waspy?", answer: "Para ocultar tu estado y ubicación solo necesitas acceder a la administración del grupo en el que deseas ocultar tu ubicación y desactivar la opción “Compartir mi ubicación con este grupo”. Los demás integrantes de este grupo ya no podrán verte en el mapa ni saber en qué dirección te encuentras."),
                     FAQItem(question: "¿Cómo puedo ocultar mi ubicación en Waspy?", answer: "Para ocultar tu estado y ubicación solo necesitas acceder a la administración del grupo en el que deseas ocultar tu ubicación y desactivar la opción “Compartir mi ubicación con este grupo”. Los demás integrantes de este grupo ya no podrán verte en el mapa ni saber en qué dirección te encuentras."),
                     FAQItem(question: "¿Waspy consume mucha batería?", answer: "En Waspy implementamos algoritmos que mantienen un equilibrio entre ahorro en el consumo de la batería y la precisión de tu localización."),
                     FAQItem(question: "¿Mi ubicación y la de los integrantes de mi grupo siempre es precisa?", answer: "Waspy hace uso de los servicios de localización de Google Maps con localización del alta precisión. Esto no garantiza un 100% de efectividad en la precisión de la ubicación de los usuarios ya que existen factores que interfieren en la comunicación de los datos tales como: Ingreso al subterráneo Estar dentro de establecimientos con demasiados muros Fallas de comunicación con los proveedores de telefonia celular Para garantizar un mejor funcionamiento de los servicios de localización de Waspy se recomienda configurar tu smartphone con los accesos a la localización en alta precisión, consulta el manual de usuario de tu dispositivo para saber como activar esta opción."),
                     FAQItem(question: "¿Waspy es gratuito?", answer: "Waspy es 100% gratuito para descargar y usar. Adicionalmente ofrecemos un plan Premium con beneficios exclusivos."),
                     FAQItem(question: "¿Qué datos personales necesito proporcionar para iniciar sesión en Waspy?", answer: "Para acceder a Waspy solo necesitas un número telefónico valido, una cuenta de correo electrónico válida y proporcionar una contraseña para la protección de tus datos. Waspy mantiene tu sesión activa incluso si cierras la app, por lo que solo necesitarás proporcionar estos datos una sola vez, a menos que cierres sesión en el menú principal de la app necesitarás proporcionar tu teléfono nuevamente."),
                     FAQItem(question: "¿Qué datos personales son visibles a otras personas dentro de la aplicación?", answer: "Tu teléfono, nombre de usuario, foto de perfil y ubicación son los únicos datos personales que son visibles a otros usuarios de Waspy y solo son visibles para los integrantes de tus grupos. Nadie que no pertenezca a tus grupos podra ver o tener acceso a tus datos personales."),
                     FAQItem(question: "¿Qué datos personales puedo modificar?", answer: "En el menú configuraciones podrás editar tu perfil Waspy modificando tu foto de perfil, nombre de usuario y correo electrónico. Como medida de seguridad, antes de poder editar tu perfil de usuario es necesario re-autenticarse por lo que tendrás que ingresar tu contraseña para poder continuar. Si olvidaste tu contraseña podrás solicitar la recuperación de la misma, donde te enviaremos un correo electrónico con instrucciones para generar una nueva contraseña."),
                     FAQItem(question: "¿Qué es un grupo?", answer: "Es un conjunto de personas que comparten un círculo social tales como un Grupo Familiar, Grupo de Amigos, Grupo de Trabajo, etc. Crea grupos en Waspy para cada uno de tus círculos sociales."),
                     FAQItem(question: "¿Cómo puedo invitar miembros a mis grupos en Waspy?", answer: "En el panel inferior del Mapa podrás encontrar un listado de los integrantes actuales de tu grupo. Hay dos formas de agregar nuevos integrantes a tus grupos, en el panel de Integrantes presiona el Botón \"Invitar más miembros\": Comparte el código del grupo (6 dígitos alfanuméricos)  con la persona que deseas agregar a tu grupo. Es necesario que la otra persona tenga instalado Waspy para que pueda ingresar manualmente el código de tu grupo. Envía un Link de Invitación a tus contactos mediante otros medios de comunicación como SMS, WhatsApp, Telegram, etc. Con un link de invitación no es necesario que el otro usuario tenga instalado Waspy ya que el link lo redireccionará a la Google Play Store o App Store para descargar la app antes de unirse a tu grupo."),
                     FAQItem(question: "¿Cómo me puedo unir al grupo de alguien más?", answer: "Si ya tienes instalado Waspy pide que te compartan el código del grupo al que te quieres unir. Entra a Waspy y en la barra de Acción presiona el ícono de mis grupos, en el diálogo emergente presiona la opción “UNIRSE” y a continuación ingresa el código del grupo (6 dígitos alfanuméricos). Otra forma de unirse a un Grupo es solicitando un Link de invitación a la persona con la que quieres compartir grupo en Waspy. No es necesario que tengas instalado Waspy."),
                     FAQItem(question: "¿Por qué no puedo ver algún miembro de mi grupo en el mapa?", answer: "Verifica si la persona que quieres buscar en el mapa sigue perteneciendo a uno de tus grupos. Si en el Panel de Integrantes puedes ver a la persona que buscas con su foto de perfil difuminada y su estado en color rojo esto indica que ha desactivado su ubicación para este grupo, por lo tanto no podrás ver su ubicación en el Mapa."),
                     FAQItem(question: "¿Cómo puedo contactar a un miembro que no esta publicando su ubicación actual?", answer: "Si un miembro en tu grupo no está compartiendo su ubicación Waspy te permite ponerte en contacto con él/ella, lo único que tienes que hacer es desplegar el Panel de Integrantes y abrir el menú de la esquina superior derecha de la persona que quieres contactar, en el diálogo emergente podrás elegir entre hacerle una llamada telefónica, enviarle un SMS o solicitarle un CheckIn. Cuando le solicitas un CheckIn a alguien de tu grupo, esta persona recibe una notificación invitándole a que haga un CheckIn."),
                     FAQItem(question: "¿Cómo puedo expulsar miembros de mi grupo?", answer: "Para expulsar a una persona de tus grupos necesitas tener derechos de administrador. Ingresa al menú Mis Grupos, elige tu grupo y en la lista de integrantes presiona la opción \"Expulsar\""),
                     FAQItem(question: "¿Cómo me puedo salir de un grupo?", answer: "Ingresa al menú Mis grupos, elige el grupo que deseas abandonar, presiona la opciona “Abandonar Grupo” en la parte inferior de la pantalla. Si eres Administrador y nadie más tiene este rol en el grupo, necesitarás asignar a otra persona como Administrador antes de poder abandonar el grupo. Si tu eres el único miembro del grupo al abandonarlo este se eliminará permanentemente del sistema por lo que no podrás regresar a el."),
                     FAQItem(question: "¿Qué es una Geocerca?", answer: "En Waspy una Geocerca es un área geográfica definida por un usuario para crear una cerca virtual que representa un lugar de interés que comparte con una o más personas en sus Grupos. Una Geocerca puede representar tu casa, trabajo, escuela, etc."),
                     FAQItem(question: "¿Quiénes saben cuando entro o salgo de una Geocerca?", answer: "Todas las personas de tu grupo comparten las mismas Geocercas, por lo tanto todo tu Grupo será notificado cuando entras o sales de alguna geocerca, incluso si no estás compartiendo tu ubicación con el Grupo."),
                     FAQItem(question: "¿Cómo puedo configurar las notificaciones de entrada y salida de mis Geocercas?", answer: "Puedes bloquear las notificaciones de entrada o salida de los otros miembros de tu grupo cuando entran o salen de alguna Geocerca. Entra al menú Mis Grupos, selecciona uno de tus grupos, en la parte inferior de la pantalla podrás configurar que tipo de notificaciones quieres recibir cuando alguien de tu grupo entra o sale de alguna Geocerca. Nota: Esta configuración no bloquea las notificaciones que tú envías cuando entras o sales de alguna Geocerca."),
                     FAQItem(question: "¿Qué es el botón de pánico?", answer: "El Botón de Pánico es una función de Waspy que te permite enviar un mensaje de auxilio a máximo tres contactos de emergencia."),
                     FAQItem(question: "¿Quiénes pueden ser mis contactos de emergencia?", answer: "Cualquier persona que tengas registrada en tu directorio telefónico puede ser tu contacto de emergencia y no es obligatorio que tengan Waspy instalado. Antes de empezar a utilizar el Botón de Pánico es necesario configurar al menos uno, y máximo 3 contactos de emergencia. Cada vez que elijas a alguien como contacto de emergencia esa persona recibirá un SMS notificando que le has elegido como contacto de emergencia e invitándolo a descargar Waspy."),
                     FAQItem(question: "¿Cómo se notifica mi emergencia?", answer: "En Android: Cuando activas el Botón de Pánico una cuenta regresiva de 10 segundos te permitirá cancelar el mensaje de auxilio, si la cuenta llega a 0 tu dispositivo enviará un SMS a todos tus contactos de emergencia registrados. El menaje llevará tu nombre de usuario en Waspy junto con la dirección postal donde activaste la alerta. En iOS: al activar el boton de panico automaticamente se genera un mensaje de ayuda con tus datos y aparece la pantalla de envio con los teléfonos de emergencia cargados. Solo presiona enviar. Nota: El funcionamiento del Botón de Pánico requiere de que el usuario cuente con un plan tarifario para poder enviar el SMS de alerta satisfactoriamente."),
                     FAQItem(question: "¿Cómo puedo acceder al botón de pánico más rápido?", answer: "Para tener acceso directo al Botón de Pánico puedes añadir a tu escritorio el Widget del Botón de Pánico (solo disponible en Android). Debes tener una sesión previa para acceder correctamente."),
                     FAQItem(question: "¿Qué es el Mapa de Alertas?", answer: "El Mapa de Alertas el la función que te permite explorar zonas en el Mapa para ver los delitos que se han reportado por otros usuarios de Waspy ultimamente."),
                     FAQItem(question: "¿Qué información me brinda el Mapa de alertas?", answer: "El Mapa de Alertas proporciona información relacionada con los delitos más comunes en la ciudad tales como: Agresiones Acosos Asaltos Moto atracos Robos En cada reporte visible en el mapa se puede visualizar el tipo de siniestro, la fecha y hora en que fue reportado."),
                     FAQItem(question: "¿Quiénes colocan las alertas en el Mapa?", answer: "Las alertas son colocadas solamente por otros usuarios de Waspy."),
                     FAQItem(question: "¿Quiénes pueden ver las alertas en el Mapa?", answer: "Cualquier usuario de Waspy puede ver las alertas enviadas por otros usuarios."),
                     FAQItem(question: "¿Cómo reporto una alerta en el Mapa?", answer: "Accede a Waspy, en la esquina superior derecha presiona el Botón de Alertas para activar el Mapa de Alertas.Navega a través del mapa para ver las alertas reportadas por otros usuarios.Para reportar una nueva alerta ubica el puntero central de la pantalla sobre el lugar del incidente, posteriormente presiona el menú inferior derecho para desplegar los diferentes tipos de siniestros."),
                     FAQItem(question: "¿Los reportes de alertas son anónimos?", answer: "Si, todos los reportes enviados por los usuarios son anónimos y en ningún momento guardan información personal de la persona que reportó."),
                     FAQItem(question: "¿La información de las alertas en el Mapa es siempre verídica?", answer: "La información mostrada en el Mapa de Alertas es retroalimentada por los mismos usuarios de Waspy. Esto no garantiza al 100% la veracidad en tiempo y forma de los hechos reportados en el Mapa.")]
        let faqView = FAQView(frame: question.frame, items: items)
        
        faqView.titleLabel.text = "Preguntas Frecuentes"
        
        // Question text color
        faqView.questionTextColor = UIColor.blue
        
        // Answer text color
        faqView.answerTextColor = UIColor.black
        
        // Question text font
        faqView.questionTextFont = UIFont(name: "HelveticaNeue-Light", size: 15)
        
        // View background color
        faqView.viewBackgroundColor = UIColor.white
        
        // Set up data detectors for automatic detection of links, phone numbers, etc., contained within the answer text.
        faqView.dataDetectorTypes = [.phoneNumber, .calendarEvent, .link]
        
        // Set color for links and detected data
        faqView.tintColor = UIColor.red
        view.addSubview(faqView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
