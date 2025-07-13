// main.js – Lógica KYM Pulse

let registroId = null;
let profesionalId = null;

// 🔍 Función para obtener parámetros de la URL
function getParam(name) {
  const url = new URL(window.location.href);
  return url.searchParams.get(name);
}

// 🔥 Al cargar la página, registrar el masaje automáticamente
window.addEventListener('DOMContentLoaded', async () => {
  profesionalId = getParam('p');
  const eventoId = getParam('idEvento') || null;

  if (!profesionalId) {
    alert('⚠️ Código inválido: falta ID del profesional.');
    return;
  }

  // Evitar registro duplicado por recarga (en memoria)
  if (sessionStorage.getItem('masajeRegistrado')) return;

  const now = new Date();
  const userAgent = navigator.userAgent;
  const plataforma = navigator.platform;

  try {
    const docRef = await db.collection('masajes').add({
      profesionalId: profesionalId,
      timestamp: now,
      eventoId: eventoId,
      userAgent: userAgent,
      plataforma: plataforma,
    });

    registroId = docRef.id;
    sessionStorage.setItem('masajeRegistrado', 'true');
    console.log(`✅ Masaje registrado con ID: ${registroId}`);
  } catch (error) {
    console.error("❌ Error al registrar masaje:", error);
  }
});

// 🟣 Función para guardar encuesta
async function enviarEncuesta() {
  if (!registroId) {
    alert('❌ No se encontró el registro del masaje.');
    return;
  }

  const satisfaccion = parseInt(document.getElementById('satisfaccion').value);
  const comodidad = parseInt(document.getElementById('comodidad').value);
  const duracionOk = document.getElementById('duracionOk').checked;

  const data = {
    encuesta: {
      satisfaccion: satisfaccion,
      comodidad: comodidad,
      duracionOk: duracionOk,
    },
  };

  try {
    await db.collection('masajes').doc(registroId).update(data);

    // Ocultar encuesta, mostrar mensaje final
    document.getElementById('survey').classList.add('hidden');
    document.getElementById('mensajeFinal').classList.remove('hidden');

    console.log("✅ Encuesta enviada");
  } catch (error) {
    console.error("❌ Error al guardar encuesta:", error);
  }
}
