const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors")({
  origin: [
    "http://localhost:57715",
    "https://app.fisiospakym.com",
  ],
});

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// 🔧 MIGRAR PROFESIONALES
exports.migrarProfesionales = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      if (req.method !== "POST") {
        return res.status(405).send("Método no permitido");
      }

      const especialidadesSnap = await db.collection("especialidades").get();
      const mapaEspecialidades = {};
      especialidadesSnap.forEach((doc) => {
        const nombre = doc.data().nombre || doc.id;
        mapaEspecialidades[doc.id] = nombre;
      });

      const profesionalesSnap = await db.collection("profesionales").get();
      let migrados = 0;

      for (const doc of profesionalesSnap.docs) {
        const ref = doc.ref;
        const data = doc.data();
        const rawServicios = data.servicios || [];

        const servicios = rawServicios.map((item) => {
          if (typeof item === "object" && item.name && item.category) return item;
          if (typeof item === "string" && item.includes("|")) {
            const [category, name] = item.split("|");
            return {
              category: category.trim(),
              name: name.trim(),
              serviceId: item,
            };
          }
          if (typeof item === "string") {
            return {
              category: "Sin categoría",
              name: item.trim(),
              serviceId: item,
            };
          }
          return {
            category: "Sin categoría",
            name: "",
            serviceId: "",
          };
        });

        const especialidades = (data.especialidades || []).map((id) => mapaEspecialidades[id] || id);

        await ref.update({ servicios, especialidades });
        migrados++;
      }

      return res.status(200).json({
        status: "ok",
        mensaje: `Se migraron ${migrados} profesionales correctamente.`,
      });
    } catch (e) {
      console.error(e);
      return res.status(500).json({
        status: "error",
        error: e.toString(),
      });
    }
  });
});

// 🔗 VINCULAR SERVICIOS CON PROFESSIONAL IDS
exports.vincularServiciosConProfesionales = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      if (req.method !== "POST") {
        return res.status(405).send("Método no permitido");
      }

      const profesionalesSnap = await db.collection("profesionales").get();
      let total = 0;

      for (const doc of profesionalesSnap.docs) {
        const profesionalId = doc.id;
        const servicios = doc.data().servicios || [];

        for (const servicio of servicios) {
          const serviceId = servicio.serviceId;
          if (!serviceId) continue;

          const serviceRef = db.collection("services").doc(serviceId);
          const serviceDoc = await serviceRef.get();
          if (!serviceDoc.exists) continue;

          const current = serviceDoc.data().professionalIds || [];

          if (!current.includes(profesionalId)) {
            current.push(profesionalId);
            await serviceRef.update({ professionalIds: current });

            console.log(`→ Vinculado: ${profesionalId} → ${serviceId}`);
            total++;
          }
        }
      }

      return res.status(200).json({
        status: "ok",
        mensaje: `Se vincularon ${total} servicios correctamente.`,
      });
    } catch (e) {
      console.error(e);
      return res.status(500).json({
        status: "error",
        error: e.toString(),
      });
    }
  });
});

// 🧼 RESET DE RELACIONES
exports.resetProfessionalLinks = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      if (req.method !== "POST") {
        return res.status(405).send("Método no permitido");
      }

      const servicesSnap = await db.collection("services").get();
      let modificados = 0;

      for (const doc of servicesSnap.docs) {
        const ref = doc.ref;
        const data = doc.data();

        if (Array.isArray(data.professionalIds) && data.professionalIds.length > 0) {
          await ref.update({ professionalIds: [] });
          modificados++;
          console.log(`🔄 Reset: ${doc.id}`);
        }
      }

      return res.status(200).json({
        status: "ok",
        mensaje: `Se limpiaron ${modificados} servicios correctamente.`,
      });
    } catch (e) {
      console.error(e);
      return res.status(500).json({
        status: "error",
        error: e.toString(),
      });
    }
  });
});
