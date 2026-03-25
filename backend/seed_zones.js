const pool = require('./src/config/db.js');

async function main() {
  try {
    // Add Zone 2
    await pool.query(
      "INSERT INTO zones (name, polygon) VALUES ($1, $2::jsonb) ON CONFLICT DO NOTHING",
      ['Zone 2', JSON.stringify([
        { lat: 18.515, lng: 73.850 },
        { lat: 18.515, lng: 73.854 },
        { lat: 18.518, lng: 73.854 },
        { lat: 18.518, lng: 73.850 }
      ])]
    );

    // Add Zone 3
    await pool.query(
      "INSERT INTO zones (name, polygon) VALUES ($1, $2::jsonb) ON CONFLICT DO NOTHING",
      ['Zone 3', JSON.stringify([
        { lat: 18.525, lng: 73.860 },
        { lat: 18.525, lng: 73.864 },
        { lat: 18.528, lng: 73.864 },
        { lat: 18.528, lng: 73.860 }
      ])]
    );

    const r = await pool.query('SELECT id, name FROM zones');
    console.log('All zones:', JSON.stringify(r.rows, null, 2));
  } catch (e) {
    console.error(e.message);
  } finally {
    process.exit(0);
  }
}
main();
