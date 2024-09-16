const sequelize = require('./config/database');
const Task = require('./models/task');

sequelize.sync({ force: true }).then(() => {
  console.log('Banco de dados sincronizado');
  process.exit();
});
