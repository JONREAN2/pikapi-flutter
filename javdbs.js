

*/


let obj = JSON.parse($response.body);
obj = {
  "success" : 1,
  "message" : null,
  "data" : {
    "user" : {
      "id" : 888888,
      "promotion_days" : 99999,
      "checkin_days" : 0,
      "want_watch_count" : 0,
      "promotion_code" : "s8rvea",
      "vip_expired_at" : "2099-09-09T22:16:31.000+08:00",
      "username" : "ios黑科技",
      "share_url" : "https://jcapnred.com/?source=s8rvea",
      "last_checkin_at" : null,
      "promote_users_count" : 5201314,
      "email" : "ioshkj@163.com",
      "is_vip" : true,
      "watched_count" : 0
    },
    "banner_type" : "payment"
  },
  "action" : null
}
;

$done({body: JSON.stringify(obj)});

