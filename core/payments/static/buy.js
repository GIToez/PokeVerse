(function () {
  'use strict';
  var config = JSON.parse(document.getElementById('config').textContent);
  var status = document.getElementById('status');
  var pack = null;
  var done = false;

  function show(text, kind) {
    status.textContent = text || '';
    status.className = 'status' + (kind ? ' ' + kind : '');
  }

  function post(path, body) {
    return fetch(path, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body)
    }).then(function (response) {
      return response.json().catch(function () { return {}; }).then(function (data) {
        if (!response.ok) {
          throw new Error(data.error || 'Something went wrong. Try again.');
        }
        return data;
      });
    });
  }

  Array.prototype.forEach.call(document.querySelectorAll('.pack'), function (button) {
    button.addEventListener('click', function () {
      if (done) {
        return;
      }
      pack = button.getAttribute('data-pack');
      Array.prototype.forEach.call(document.querySelectorAll('.pack'), function (other) {
        other.classList.toggle('selected', other === button);
      });
      show('');
    });
  });

  function buttons() {
    window.paypal.Buttons({
      style: { layout: 'vertical', color: 'gold', shape: 'rect', label: 'pay' },
      onClick: function (data, actions) {
        if (!pack) {
          show('Choose a pack first.', 'error');
          return actions.reject();
        }
        return actions.resolve();
      },
      createOrder: function () {
        show('');
        return post('/api/orders', { t: config.token, pack: pack }).then(function (data) {
          return data.id;
        }).catch(function (error) {
          show(error.message, 'error');
          throw error;
        });
      },
      onApprove: function (data, actions) {
        show('Adding your orbs...');
        return post('/api/capture', { t: config.token, orderID: data.orderID }).then(function (result) {
          if (result.restart) {
            show(result.message, 'error');
            return actions.restart();
          }
          if (typeof result.balance === 'number') {
            document.getElementById('balance').textContent = result.balance.toLocaleString('en-US');
          }
          if (result.ok && !result.pending) {
            done = true;
            document.getElementById('paypal').style.display = 'none';
            document.getElementById('packs').classList.add('done');
          }
          show(result.message, result.ok ? 'ok' : 'error');
        }).catch(function (error) {
          show(error.message, 'error');
        });
      },
      onCancel: function () {
        show('Payment cancelled. Nothing was charged.');
      },
      onError: function () {
        show('PayPal could not start the payment. Reload the page and try again.', 'error');
      }
    }).render('#paypal');
  }

  var sdk = document.createElement('script');
  sdk.src = config.sdk;
  sdk.onload = buttons;
  sdk.onerror = function () {
    show('PayPal could not be loaded. Check your connection and reload the page.', 'error');
  };
  document.head.appendChild(sdk);
})();
