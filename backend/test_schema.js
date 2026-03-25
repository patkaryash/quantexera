const pool = require('./src/config/db.js');
async function main() {
  try {
    const r = await pool.query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'attendance'");
    console.log('ATTENDANCE:', JSON.stringify(r.rows, null, 2));
    const r2 = await pool.query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'locations'");
    console.log('LOCATIONS:', JSON.stringify(r2.rows, null, 2));
  } catch(e) { console.error(e.message); }
  finally { process.exit(0); }
}
main();
