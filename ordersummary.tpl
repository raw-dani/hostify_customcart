{*{print_r($producttotals.configoptions)}*}
{* {if $producttotals.pid == $idproduk}
    <img src="/assets/img/diskon/EIKON30.png" alt="diskon" width="100%" height="100%">
{/if} *}

{if $producttotals}
    <span class="product-name">{if $producttotals.allowqty && $producttotals.qty > 1}{$producttotals.qty} x {/if}{$producttotals.productinfo.name}</span>
    <span class="product-group">{$producttotals.productinfo.groupname}</span>

    <div class="clearfix">
        <span class="pull-left float-left">{$producttotals.productinfo.name}</span>
        <span class="pull-right float-right">Rp. {$producttotals.pricing.baseprice|regex_replace:'/[^0-9.]/':''|number_format:2:".":","} IDR</span>
    </div>

    {* nilai diskon 30%            *}
    {* {print_r($maxusepromo)} *}
    {assign var="percentage" value=30}
    {assign var="lisensi" value=20}
    {assign var="idproduk" value=2}
    {foreach $producttotals.configoptions as $configoption}
        {if $configoption}
            {if $producttotals.pid == $idproduk}
                {$texttemp = 'Selamat untuk pembelian dibawah 20 lisensi anda mendapatkan diskon khusus 30%'}
                {$defaultprice = $configoption.recurring}
                {$prices = explode(" ",$configoption.recurring)}
                {$d = explode(",",$prices[1])}
                {assign var="depan" value=$d[0]}
                {assign var="belakang" value=$d[1]}
                {assign var="belakang2" value=$d[2]}
                {$harga = "$depan$belakang$belakang2"}      

                {* nilai diskon 30%            *}
                {* {print_r($maxusepromo)} *}
                {assign var="percentage" value=30}
                {assign var="lisensi" value=20}
                {math assign="persen" equation='x/y*h' y=100 x=$percentage h=$harga}    
                {math assign="sumprice" equation='y-x' y=$harga x=$persen} 
                {* {math assign="sumplus" equation='y+x' y=$harga x=$sumprice} *}

                {math assign="hargadasar" equation='y/x' y=$harga x=$configoption.optionname}
                {math assign="hargafix" equation='y*x' y=$lisensi x=$hargadasar}
                {math assign="persenfix" equation='x/y*h' y=100 x=$percentage h=$hargafix}
                {math assign="sumpricefix" equation='y-x' y=$hargafix x=$persenfix}

                {math assign="lisensilebih" equation='x-y' y=$lisensi x=$configoption.optionname}
                {math assign="harganormal" equation='y*x' y=$hargadasar x=$lisensilebih}

                {math assign="jumlah" equation='y+x' y=$harganormal x=$sumpricefix}

                

                    {if $config_qty <= $lisensi}
                        <div class="clearfix">
                            <span class="pull-left float-left">&nbsp;&raquo; {$configoption.name}: {$config_qty}</span><br>
                            <span class="pull-left float-left">&nbsp;&raquo; {$harga|regex_replace:'/[^0-9.]/':''|number_format:2:".":","} - {$percentage}%</span>
                            <span class="pull-right float-right">Rp. {$sumprice|regex_replace:'/[^0-9.]/':''|number_format:2:".":","} IDR</span>
                        </div>
                        {$configoption.recurring = $sumprice}
                    {else}
                        {$configoption.recurring = $jumlah}

                        <div class="clearfix">
                            <span class="pull-left float-left">&nbsp;&raquo; {$configoption.name}: {$config_qty}</span><br>

                            {if $config_qty > 5}
                                <span class="pull-left float-left">&nbsp;&raquo; {$hargafix|regex_replace:'/[^0-9.]/':''|number_format:2:".":","} - {$percentage}% Seats: {$lisensi}</span>
                                <span class="pull-right float-right">Rp. {$sumpricefix|regex_replace:'/[^0-9.]/':''|number_format:2:".":","} IDR</span><br>
                                <span class="pull-left float-left">&nbsp;&raquo; {$harganormal|regex_replace:'/[^0-9.]/':''|number_format:2:".":","} Seats: {$lisensilebih}</span>
                                <span class="pull-right float-right">Rp. {$harganormal|regex_replace:'/[^0-9.]/':''|number_format:2:".":","} IDR</span>
                            {/if}
                        </div>
                    {/if}
                {else}
                    {* Fallback jika harga tidak valid *}
                    <div class="clearfix">
                        <span class="pull-left float-left">&nbsp;&raquo; {$configoption.name}: {$configoption.optionname|default:0}</span>
                        <span class="pull-right float-right">{$configoption.recurring|default:'N/A'}</span>
                    </div>
                {/if}
            {else}
                <div class="clearfix">
                    <span class="pull-left float-left">&nbsp;&raquo; {$configoption.name}: {$configoption.optionname}</span>
                    <span class="pull-right float-right">Rp. {$configoption.recurring|number_format:2:".":","} IDR{if $configoption.setup} + Rp. {$configoption.setup|number_format:2:".":","} IDR {$LANG.ordersetupfee}{/if}</span>
                </div>
            {/if}
        {/if}
    {/foreach}

    {foreach $producttotals.addons as $addon}
        <div class="clearfix">
            <span class="pull-left float-left">+ {$addon.name}</span>
            <span class="pull-right float-right">Rp. {$addon.recurring|number_format:2:".":","} IDR</span>
        </div>    
    {/foreach}

    {if $producttotals.pricing.addons}
        <div class="summary-totals">
            {if $producttotals.pricing.setup}
                <div class="clearfix">
                    <span class="pull-left float-left">{$LANG.cartsetupfees}:</span>
                    <span class="pull-right float-right">Rp. {$producttotals.pricing.setup|number_format:2:".":","} IDR</span>
                </div>
            {/if}
            {foreach from=$producttotals.pricing.recurringexcltax key=cycle item=recurring}
                <div class="clearfix">
                    <span class="pull-left float-left">{$cycle}:</span>
                    <span class="pull-right float-right">Rp. {$recurring|number_format:2:".":","} IDR</span>
                </div>
            {/foreach}
            {if $producttotals.pricing.tax1}
                <div class="clearfix">
                    <span class="pull-left float-left">{$carttotals.taxname} @ {$carttotals.taxrate}%:</span>
                    <span class="pull-right float-right">Rp. {$producttotals.pricing.tax1|number_format:2:".":","} IDR</span>
                </div>
            {/if}
            {if $producttotals.pricing.tax2}
                <div class="clearfix">
                    <span class="pull-left float-left">{$carttotals.taxname2} @ {$carttotals.taxrate2}%:</span>
                    <span class="pull-right float-right">Rp. {$producttotals.pricing.tax2|number_format:2:".":","} IDR</span>
                </div>
            {/if}
        </div>
    {/if}
    
    {if $producttotals.pricing.setup || $producttotals.pricing.recurring}
        {* setup pajak *}
        {math assign="taxpersen" equation='x/y*h' y=100 x=11 h=$configoption.recurring}
        {math assign="totalday" equation='x+y' y=$taxpersen x=$configoption.recurring}

        <div class="summary-totals">
            {if $producttotals.pricing.setup}
                <div class="clearfix">
                    <span class="pull-left float-left">{$LANG.cartsetupfees}:</span>
                    <span class="pull-right float-right">{$producttotals.pricing.setup}</span>
                </div>
            {/if}
            {foreach from=$producttotals.pricing.recurringexcltax key=cycle item=recurring}
                {if $producttotals.pid == $idproduk}
                    <div class="clearfix">
                        <span class="pull-left float-left">{$cycle}:</span>
                        <span class="pull-right float-right">Rp. {$configoption.recurring|regex_replace:'/[^0-9.]/':''|number_format:2:".":","} IDR</span>
                    </div>
                {else}
                    <div class="clearfix">
                        <span class="pull-left float-left">{$cycle}:</span>
                        <span class="pull-right float-right">Rp. {$recurring|number_format:2:".":","} IDR</span>
                    </div>
                {/if}
            {/foreach}
            {if $producttotals.pricing.tax1}
                {if $producttotals.pid == $idproduk}
                    <div class="clearfix">
                        <span class="pull-left float-left">{$carttotals.taxname} @ {$carttotals.taxrate}%:</span>
                        <span class="pull-right float-right">Rp. {$taxpersen|regex_replace:'/[^0-9.]/':''|number_format:2:".":","} IDR</span>
                    </div>
                {else}
                    <div class="clearfix">
                        <span class="pull-left float-left">{$carttotals.taxname} @ {$carttotals.taxrate}%:</span>
                        <span class="pull-right float-right">Rp. {$producttotals.pricing.tax1|number_format:2:".":","} IDR</span>
                    </div>
                {/if}
            {/if}
            {if $producttotals.pricing.tax2}
                <div class="clearfix">
                    <span class="pull-left float-left">{$carttotals.taxname2} @ {$carttotals.taxrate2}%:</span>
                    <span class="pull-right float-right">{$producttotals.pricing.tax2}</span>
                </div>
            {/if}
        </div>
    {/if}

   
        {if $producttotals.pid == $idproduk}

            {$producttotals.pricing.totaltoday = $totalday}
            
            {if $configoption.optionname <= $lisensi}
                <div class="total-due-today">
                    <span class="amt">Rp. {$totalday|regex_replace:'/[^0-9.]/':''|number_format:2:".":","} IDR</span>
                    <span>{$LANG.ordertotalduetoday}</span>
                </div>
            {else}
                <div class="total-due-today">
                    <span class="amt">Rp. {$totalday|regex_replace:'/[^0-9.]/':''|number_format:2:".":","} IDR</span>
                    <span>{$LANG.ordertotalduetoday}</span>
                </div>
            {/if}
        {else}
            <div class="total-due-today">
                <span class="amt">Rp. {$producttotals.pricing.totaltoday|regex_replace:'/[^0-9.]/':''|number_format:2:".":","} IDR</span>
                <span>{$LANG.ordertotalduetoday}</span>
            </div>
        {/if}
    
{elseif $renewals}
    {if $carttotals.renewals}
        <span class="product-name">{lang key='domainrenewals'}</span>
        {foreach $carttotals.renewals as $domainId => $renewal}
            <div class="clearfix" id="cartDomainRenewal{$domainId}">
                <span class="pull-left float-left">
                    {$renewal.domain} - {$renewal.regperiod} {if $renewal.regperiod == 1}{lang key='orderForm.year'}{else}{lang key='orderForm.years'}{/if}
                </span>
                <span class="pull-right float-right">
                    Rp. {$renewal.priceBeforeTax|number_format:2:".":","} IDR
                    <a onclick="removeItem('r','{$domainId}'); return false;" href="#" id="linkCartRemoveDomainRenewal{$domainId}">
                        <i class="fas fa-fw fa-trash-alt"></i>
                    </a>
                </span>
            </div>
            {if $renewal.dnsmanagement}
                <div class="clearfix">
                    <span class="pull-left float-left">+ {lang key='domaindnsmanagement'}</span>
                </div>
            {/if}
            {if $renewal.emailforwarding}
                <div class="clearfix">
                    <span class="pull-left float-left">+ {lang key='domainemailforwarding'}</span>
                </div>
            {/if}
            {if $renewal.idprotection}
                <div class="clearfix">
                    <span class="pull-left float-left">+ {lang key='domainidprotection'}</span>
                </div>
            {/if}
            {if $renewal.hasGracePeriodFee}
                <div class="clearfix">
                    <span class="pull-left float-left">+ {lang key='domainRenewal.graceFee'}</span>
                </div>
            {/if}
            {if $renewal.hasRedemptionGracePeriodFee}
                <div class="clearfix">
                    <span class="pull-left float-left">+ {lang key='domainRenewal.redemptionFee'}</span>
                </div>
            {/if}

        {/foreach}
    {/if}
    <div class="summary-totals">
        <div class="clearfix">
            <span class="pull-left float-left">{lang key='ordersubtotal'}:</span>
            <span class="pull-right float-right">Rp. {$carttotals.subtotal|regex_replace:'/[^0-9.]/':''|number_format:2:".":","} IDR</span>
        </div>
        {if ($carttotals.taxrate && $carttotals.taxtotal) || ($carttotals.taxrate2 && $carttotals.taxtotal2)}
            {if $carttotals.taxrate}
                <div class="clearfix">
                    <span class="pull-left float-left">{$carttotals.taxname} @ {$carttotals.taxrate}%:</span>
                    <span class="pull-right float-right">Rp. {$carttotals.taxtotal|regex_replace:'/[^0-9.]/':''|number_format:2:".":","} IDR</span>
                </div>
            {/if}
            {if $carttotals.taxrate2}
                <div class="clearfix">
                    <span class="pull-left float-left">{$carttotals.taxname2} @ {$carttotals.taxrate2}%:</span>
                    <span class="pull-right float-right">Rp. {$carttotals.taxtotal2|regex_replace:'/[^0-9.]/':''|number_format:2:".":","} IDR</span>
                </div>
            {/if}
        {/if}
    </div>
    <div class="total-due-today">
        <span class="amt">Rp. {$carttotals.total|regex_replace:'/[^0-9.]/':''|number_format:2:".":","} IDR</span>
        <span>{lang key='ordertotalduetoday'}</span>
    </div>
{/if}
