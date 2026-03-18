module.exports = async function handler(_req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  return res.status(200).json({
    ok: true,
    service: 'formisra-backend',
  });
};
