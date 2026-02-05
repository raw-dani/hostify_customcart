/**
 * Hostify Custom Cart - JavaScript Functions
 * Fungsi-fungsi AJAX dan helper untuk orderform
 */

/**
 * Fungsi untuk menghitung ulang total harga produk (AJAX)
 * Dipanggil saat mengubah billing cycle atau configurable options
 */
function recalctotals() {
    if (typeof jQuery === 'undefined') {
        console.error('jQuery not loaded');
        return;
    }

    var form = jQuery('#frmConfigureProduct');
    if (form.length === 0) {
        return;
    }

    // Tampilkan loader
    jQuery('#orderSummaryLoader').removeClass('w-hidden');
    jQuery('#producttotal').html('');

    // Disable tombol continue
    jQuery('#btnCompleteProductConfig').prop('disabled', true);

    // Ambil data form
    var formData = form.serialize();
    formData += '&a=confproduct&calctotal=true';

    // AJAX request
    jQuery.ajax({
        url: window.location.pathname,
        type: 'POST',
        data: formData,
        dataType: 'json',
        success: function(data, textStatus, xhr) {
            try {
                // Check if response is valid JSON
                if (typeof data === 'object' && data !== null) {
                    if (data.producttotal) {
                        jQuery('#producttotal').html(data.producttotal);
                    } else if (data.error) {
                        console.error('Server error:', data.error);
                        jQuery('#producttotal').html('<div class="alert alert-danger">Error: ' + data.error + '</div>');
                    }
                } else {
                    console.error('Invalid JSON response format');
                    jQuery('#producttotal').html('<div class="alert alert-warning">Unable to calculate totals. Please refresh the page.</div>');
                }
            } catch (e) {
                console.error('Error processing response:', e);
                jQuery('#producttotal').html('<div class="alert alert-danger">Error processing server response.</div>');
            }
        },
        error: function(xhr, status, error) {
            console.error('Error calculating totals:', error);
            console.error('Status:', status);
            console.error('Response:', xhr.responseText);

            // Try to parse error response
            try {
                var errorData = JSON.parse(xhr.responseText);
                if (errorData && errorData.error) {
                    jQuery('#producttotal').html('<div class="alert alert-danger">Error: ' + errorData.error + '</div>');
                } else {
                    jQuery('#producttotal').html('<div class="alert alert-danger">Unable to calculate totals. Please try again.</div>');
                }
            } catch (e) {
                // If response is not JSON, show generic error
                jQuery('#producttotal').html('<div class="alert alert-danger">Unable to calculate totals. Please refresh the page.</div>');
            }
        },
        complete: function() {
            // Sembunyikan loader
            jQuery('#orderSummaryLoader').addClass('w-hidden');
            // Enable tombol continue
            jQuery('#btnCompleteProductConfig').prop('disabled', false);
        }
    });
}

/**
 * Fungsi untuk update configurable options berdasarkan billing cycle
 * @param {number} i - Index produk
 * @param {string} billingCycle - Billing cycle yang dipilih
 */
function updateConfigurableOptions(i, billingCycle) {
    if (typeof jQuery === 'undefined') {
        console.error('jQuery not loaded');
        return;
    }

    // Tampilkan loader
    jQuery('#orderSummaryLoader').removeClass('w-hidden');

    // AJAX request untuk update options
    jQuery.ajax({
        url: window.location.pathname,
        type: 'POST',
        data: {
            a: 'confproduct',
            i: i,
            billingcycle: billingCycle,
            updateoptions: true
        },
        dataType: 'json',
        success: function(data) {
            if (data && data.configurableoptions) {
                // Update configurable options container
                jQuery('#productConfigurableOptions').html(data.configurableoptions);
                // Re-initialize event listeners
                initConfigurableOptions();
            }
            // Hitung ulang total
            recalctotals();
        },
        error: function(xhr, status, error) {
            console.error('Error updating configurable options:', error);
            // Tetap hitung ulang total
            recalctotals();
        },
        complete: function() {
            // Sembunyikan loader
            jQuery('#orderSummaryLoader').addClass('w-hidden');
        }
    });
}

/**
 * Initialize event listeners untuk configurable options
 */
function initConfigurableOptions() {
    // Radio buttons dan checkboxes
    jQuery('input[type="radio"][name^="configoption["], input[type="checkbox"][name^="configoption["]').on('change', function() {
        recalctotals();
    });

    // Select dropdowns
    jQuery('select[name^="configoption["]').on('change', function() {
        recalctotals();
    });

    // Number inputs
    jQuery('input[type="number"][name^="configoption["]').on('input', function() {
        // Debounce untuk number input
        clearTimeout(window.recalcTimeout);
        window.recalcTimeout = setTimeout(recalctotals, 500);
    });
}

/**
 * Fungsi untuk update domain period in cart
 * @param {string} domain - Nama domain
 * @param {string} price - Harga
 * @param {number} years - Jumlah tahun
 * @param {string} yearsText - Text tahun
 */
function selectDomainPeriodInCart(domain, price, years, yearsText) {
    if (typeof jQuery === 'undefined') {
        console.error('jQuery not loaded');
        return false;
    }

    // Update price display
    jQuery('span[name="' + domain + 'Price"]').text(price);
    
    // Update dropdown button text
    jQuery('#' + domain + 'Pricing').html(years + ' ' + yearsText + ' <span class="caret"></span>');
    
    // Trigger recalculation
    recalctotals();
    
    return false;
}

/**
 * Fungsi untuk menghapus item dari cart
 * @param {string} type - Tipe item (p=product, a=addon, d=domain, r=renewal, u=upgrade)
 * @param {string|number} ref - Reference/index item
 */
function removeItem(type, ref) {
    if (typeof jQuery === 'undefined') {
        console.error('jQuery not loaded');
        return;
    }

    jQuery('#inputRemoveItemType').val(type);
    jQuery('#inputRemoveItemRef').val(ref);
    jQuery('#modalRemoveItem').modal('show');
}

/**
 * Document ready - Initialize semua event listeners
 */
jQuery(document).ready(function() {
    // Initialize configurable options
    initConfigurableOptions();

    // Form submit handler untuk configure product
    jQuery('#frmConfigureProduct').on('submit', function(e) {
        // Validasi form jika diperlukan
        var form = jQuery(this);
        var errors = [];

        // Check required fields
        form.find('input[required], select[required]').each(function() {
            if (!jQuery(this).val()) {
                errors.push(jQuery(this).attr('name'));
            }
        });

        if (errors.length > 0) {
            e.preventDefault();
            alert('Please fill in all required fields.');
            return false;
        }
    });

    // Addon selection handler
    jQuery('.panel-addon').on('click', function(e) {
        if (e.target.tagName.toLowerCase() !== 'input') {
            var checkbox = jQuery(this).find('input[type="checkbox"]');
            checkbox.prop('checked', !checkbox.prop('checked'));
            jQuery(this).toggleClass('panel-addon-selected', checkbox.prop('checked'));
            recalctotals();
        }
    });

    // Prevent double click pada tombol submit
    jQuery('#btnCompleteProductConfig').on('click', function(e) {
        if (jQuery(this).prop('disabled')) {
            e.preventDefault();
            return false;
        }
        jQuery(this).prop('disabled', true);
    });

    // Initialize tooltips
    if (typeof jQuery.fn.tooltip !== 'undefined') {
        jQuery('[data-toggle="tooltip"]').tooltip();
    }

    // Initialize popovers
    if (typeof jQuery.fn.popover !== 'undefined') {
        jQuery('[data-toggle="popover"]').popover();
    }
});

/**
 * Fungsi helper untuk format currency
 * @param {number} amount - Jumlah
 * @param {string} prefix - Prefix currency
 * @param {string} suffix - Suffix currency
 * @returns {string} Formatted currency
 */
function formatCurrency(amount, prefix, suffix) {
    prefix = prefix || '';
    suffix = suffix || '';
    return prefix + parseFloat(amount).toFixed(2) + suffix;
}

/**
 * Fungsi helper untuk debounce
 * @param {function} func - Fungsi yang akan di-debounce
 * @param {number} wait - Waktu tunggu dalam ms
 * @returns {function}
 */
function debounce(func, wait) {
    var timeout;
    return function() {
        var context = this, args = arguments;
        clearTimeout(timeout);
        timeout = setTimeout(function() {
            func.apply(context, args);
        }, wait);
    };
}